(* open Nomad *)
open Bos_setup
open Kwdcmd

module Common = struct
  (* TODO WHY IS THIS NOT ENDING UP IN THE MANPAGE? *)
  let docs = Cmdliner.Manpage.s_options

  let opts =
    let+ debug =
      Optional.flag
        ~flags:[ "d"; "debug" ]
        ~doc:"set logging to debug level"
        ~docs
        ()
    in
    (if debug then Logs.(set_level (Some Debug)));
    Nomad.Common.{ debug }
end

module Add = struct
  let config =
    let+ ocamlformat =
      Optional.flag ~flags:[ "ocamlformat" ] ~doc:"add a .ocamlformat file" ()
    in
    Nomad.Add.{ ocamlformat }

  let cmd =
    cmd
      ~name:"add"
      ~doc:"add components"
      (const Nomad.Add.run $ Common.opts $ config)
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
      (const Nomad.New_project.run $ Common.opts $ config)
end

module Sync = struct
  let cmd =
    cmd
      ~name:"sync"
      ~doc:"synchronize dependencies"
      (const Nomad.Sync.run $ Common.opts)
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
