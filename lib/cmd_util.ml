open Bos

type result = (unit, Rresult.R.msg) Rresult.result

let run cmd = OS.Cmd.(run_out ~err:err_run_out cmd |> out_string)

let run_success cmd = run cmd |> OS.Cmd.success |> Result.map ignore
