open Bos

let bin = Cmd.v "opam"

let create_switch () =
    Cmd_util.run Cmd.(bin % "switch" % "create" % "." % "--deps-only" % "--with-test" % "--quiet" % "--yes")

(* TODO Make "y optional?" *)
let install_deps () =
  Cmd_util.run Cmd.(bin % "install" % "--yes" % "." % "--deps-only" % "--with-test")
