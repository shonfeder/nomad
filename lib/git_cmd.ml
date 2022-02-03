open Bos

let bin = Cmd.v "git"

let init () = Cmd_util.run Cmd.(bin % "init")
let add files = Cmd_util.run Cmd.(bin % "add" %% of_list files)

let changed_files () =
  Cmd.(bin % "diff" % "--name-only" % "HEAD")
  |> OS.Cmd.(run_out ~err:err_run_out)
  |> OS.Cmd.to_lines ~trim:true

let commit msg = Cmd_util.run Cmd.(bin % "commit" % "-m" % msg)
