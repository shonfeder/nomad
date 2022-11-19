open Bos

let bin = Cmd.v "opam"

let switch = Cmd.(bin % "switch")

let create_switch () =
  Cmd_util.run
    Cmd.(
      switch
      % "create"
      % "."
      % "--deps-only"
      % "--with-test"
      % "--quiet"
      % "--yes")

let current_switch () = Cmd_util.run_out Cmd.(switch % "show")

(* TODO Make "y optional?" *)
let install_deps () =
  Cmd_util.run
    Cmd.(bin % "install" % "--yes" % "." % "--deps-only" % "--with-test")

let pin url = Cmd_util.run Cmd.(bin % "pin" % "--yes" % url)
