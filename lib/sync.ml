(* TODO *)
open Bos

let run = OS.Cmd.(run ~err:err_run_out)

module Git = struct
  let bin = Cmd.v "git"

  let add files = run Cmd.(bin % "add" %% of_list files)

  let changed_files () =
    Cmd.(bin % "diff" % "--name-only" % "HEAD")
    |> OS.Cmd.(run_out ~err:err_run_out)
    |> OS.Cmd.to_lines ~trim:true

  let commit msg = run Cmd.(bin % "commit" % "-m" % msg)
end

module Dune = struct
  let bin = Cmd.v "dune"

  (* TODO find the root first *)
  let build () =
    let cmd = Cmd.(bin % "build") in
    OS.Cmd.(run_out ~err:err_run_out cmd |> out_string)

  let warn_on_lib_not_found = function
    | Ok (output, (_, `Exited 1)) as result ->
        if not Bos.Pat.(matches (v {|Error: Library $(LIB) not found.|}) output)
        then
          OS.Cmd.success result
        else (
          Logs.warn (fun fmt ->
              fmt "dune build failed -- assuming dependecy unmet");
          Ok ""
        )
    | result -> OS.Cmd.success result
end

module Opam = struct
  let bin = Cmd.v "opam"

  (* TODO Make "y optional?" *)
  let install_deps () =
    run Cmd.(bin % "install" % "--yes" % "." % "--deps-only" % "--with-test")
end

let ( let* ) = Rresult.( >>= )

(** Convert all pattern variables to '*', to make it into a shell glob *)
let pat_to_glob pat =
  Pat.format ~undef:(fun _ -> "*") Astring.String.Map.empty pat

let dep_spec_file f =
  Pat.(matches (v "dune-project") f || matches (v "$(PACK).opam") f)

(* TODO add support for common opts *)
(* TODO add logic to run updates on pindeps? *)
let run _opts =
  let* _ = Dune.build () |> Dune.warn_on_lib_not_found in
  let* () =
    let* files =
      Git.changed_files () |> Result.map (fun f -> List.filter dep_spec_file f)
    in
    match files with
    | []    -> Ok ()
    | files ->
        let* () = Git.add files in
        Git.commit "Update dependencies"
  in
  let* () = Opam.install_deps () in
  let* res = Dune.build () in
  Ok (ignore res)
