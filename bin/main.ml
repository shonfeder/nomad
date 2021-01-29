(* open Nomad *)
open Kwdcmd

module Add = struct
  let config =
    let+ ocamlformat =
      Optional.flag ~flags:[ "ocamlformat" ] ~doc:"add a .ocamlformat file" ()
    in
    Nomad.Add.{ ocamlformat }

  let cmd = cmd ~name:"add" ~doc:"add components" (const Nomad.Add.run $ config)
end

module New = struct
  module Kind = Nomad.New_project.Kind

  let config =
    let+ name =
      Required.pos
        "NAME"
        ~conv:Arg.string
        ~nth:0
        ~doc:"The name of the new project"
        ()
    and+ kind =
      (* TODO Use different option that allows mutually exlusive kinds *)
      Optional.(
        flag_choice
          ~default:Kind.Binary
          [ c ~name:"bin" Kind.Binary ~doc:"create an executable binary"
          ; c ~name:"lib" Kind.Library ~doc:"create a library"
          ])
    in
    Nomad.New_project.{ name; kind }

  (* TODO also take a Add config, to allow specifing parts to ommit?  *)
  let cmd =
    cmd
      ~name:"new"
      ~doc:"begin a new project"
      (const Nomad.New_project.run $ config)
end

module Sync = struct
  let cmd =
    cmd
      ~name:"sync"
      ~doc:"synchronize dependencies"
      (const Nomad.Sync.run $ unit)
end

(* TODO: Allow adding existing directory with `init` *)
(* TODO Should be namespaced under "new" subcommand *)
let () =
  Cmdliner.Term.exit
  @@ Exec.select
       ~name:"nomad"
       ~version:"%%VERSION%%"
       ~doc:"roam freely, building projects and packages with ease"
       [ New.cmd; Sync.cmd; Add.cmd ]
