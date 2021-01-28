(* open Nomad *)
open Kwdcmd

(* TODO: Allow adding existing directory with `init` *)
(* TODO Should be namespaced under "new" subcommand *)
let () =
  Cmdliner.Term.exit
  @@ Exec.select
       ~name:"nomad"
       ~version:"%%VERSION%%"
       ~doc:"roam freely, building projects and packages with ease"
       [ New_cmd.cmd; Sync_cmd.cmd ]
