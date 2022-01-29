open Bos

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
