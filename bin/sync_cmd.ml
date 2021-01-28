open Kwdcmd

let cmd =
  cmd ~name:"sync" ~doc:"synchronize dependencies" (const Nomad.Sync.run $ unit)
