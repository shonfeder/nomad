open Bos

let bin = Cmd.v "dune"

(* TODO find the root first *)
let build () = Cmd_util.run_out Cmd.(bin % "build")
let fmt () = Cmd_util.run Cmd.(bin % "build" % "@fmt" % "--auto-promote")
let lib_not_found_re = Str.regexp {|Error: Library .* not found|}

let warn_on_lib_not_found = function
  | Ok (output, (_, `Exited 1)) ->
    (try
       ignore (Str.search_forward lib_not_found_re output 0);
       Logs.warn (fun fmt ->
           fmt "dune build failed with unfound library, nomad will now update dependecies");
       Ok ()
     with Not_found -> Rresult.R.error_msgf "dune build failed with error: %s" output)
  | result ->
    OS.Cmd.success result |> Result.map ignore

let init : string -> Project.Kind.t -> Cmd_util.result =
 fun name kind ->
  let kind = "--kind=" ^ Project.Kind.to_string kind in
  Cmd_util.run_success Cmd.(bin % "init" % "project" % kind % name)
