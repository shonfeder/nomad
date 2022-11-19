open Bos

type result = (unit, Rresult.R.msg) Rresult.result

let run = OS.Cmd.(run ~err:err_run_out)
let run_out cmd = OS.Cmd.(run_out ~err:err_run_out cmd |> out_string)
let run_success cmd =
  let cmd_str = Cmd.to_string cmd in
  match run_out cmd with
  | Ok (output, (_, `Exited 0)) ->
    Logs.debug (fun f -> f "command %s succeeded with %s" cmd_str output);
    Ok ()
  | Ok (output, (_, `Exited c)) ->
    let msg = Printf.sprintf {|command %s failed with exit code %i and the following output:
---
%s
---
|}
        cmd_str c output
    in
    Logs.debug (fun f -> f "%s" msg);
    Rresult.R.error_msg  msg
  | result -> OS.Cmd.success result |> Result.map ignore
