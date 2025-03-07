open Bos

let bin = Cmd.v "opam"

let switch = Cmd.(bin % "switch")
let install = Cmd.(bin % "install" % "--yes" )

let create_switch () =
  Cmd_util.run
    Cmd.(
      switch
      % "create"
      % "."
      % "--working-dir"
      % "--deps-only"
      % "--with-test"
      % "--with-dev-setup"
      % "--quiet"
      % "--yes")

let current_switch () = Cmd_util.run_out Cmd.(switch % "show")

let install_pkgs = function
  | []   -> Ok () (* No-op *)
  | pkgs -> Cmd_util.run_success Cmd.(install %% of_list pkgs)

(* TODO Make "y optional?" *)
let install_deps () =
  Cmd_util.run
    Cmd.(install % "." % "--working-dir" % "--deps-only" % "--with-test")

let pin url = Cmd_util.run Cmd.(bin % "pin" % "--yes" % url)
