open Bos

type result = (unit, Rresult.R.msg) Rresult.result

let run = OS.Cmd.(run ~err:err_run_out)
let run_out cmd = OS.Cmd.(run_out ~err:err_run_out cmd |> out_string)
let run_success cmd = run_out cmd |> OS.Cmd.success |> Result.map ignore
