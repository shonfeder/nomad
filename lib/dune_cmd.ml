open Bos

let bin = Cmd.v "dune"

(* TODO find the root first *)
let build () =
  Cmd_util.run_out Cmd.(bin % "build")

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

let init : string -> Project.Kind.t -> Cmd_util.result  =
  fun name kind ->
  let kind = "--kind=" ^ Project.Kind.to_string kind in
  Cmd_util.run_success Cmd.(bin % "init" % "project" % kind % name)
