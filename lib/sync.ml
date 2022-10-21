(* TODO *)
open Bos

let dep_spec_file f =
  Pat.(matches (v "dune-project") f || matches (v "$(PACK).opam") f)

(* TODO add support for common opts *)
(* TODO add logic to run updates on pindeps? *)
let run _opts =
  Result.of_rresult
  @@
  let open Result.Let in
  let* _ = Dune_cmd.build () |> Dune_cmd.warn_on_lib_not_found in
  let* () =
    let* files =
      Git_cmd.changed_files ()
      |> Result.map (fun f -> List.filter dep_spec_file f)
    in
    match files with
    | [] -> Ok ()
    | files ->
        let* () = Git_cmd.add files in
        Git_cmd.commit "Update dependencies"
  in
  let* () = Opam_cmd.install_deps () in
  let* _ = Dune_cmd.build () in
  Ok ()
