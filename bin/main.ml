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
  let cmd =
    cmd ~name:"add" ~doc:"add components"
    @@ let+ opts = Common.opts
       and+ ocamlformat =
         Optional.flag
           ~flags:[ "ocamlformat" ]
           ~doc:"add a .ocamlformat file"
           ()
       in
       Nomad.Add.(run opts { ocamlformat })
end

module New = struct
  module Kind = Nomad.Project.Kind

  (* TODO: Allow adding existing directory with `init` *)
  (* TODO also take a Add config, to allow specifing parts to ommit?  *)
  let cmd =
    cmd ~name:"new" ~doc:"begin a new project"
    @@ let+ opts = Common.opts
       and+ name =
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
       Nomad.New_project.(run opts { name; kind })
end

module Sync = struct
  let cmd =
    cmd ~name:"sync" ~doc:"synchronize dependencies"
    @@ let+ opts = Common.opts in
       Nomad.Sync.run opts
end

(* module Subst = struct
 *   let cmd =
 *     cmd ~name:"subst" ~doc:"substitute template vars"
 *       @@ let+ opts = Common.opts in
 *       (\* TODO support for custom substutition params *\)
 *       Nomad.Sust.run opts
 * end *)

let () =
  Exec.commands
    ~name:"nomad"
    ~version:"%%VERSION%%"
    ~doc:"roam freely, building projects and packages with ease"
    [ New.cmd; Sync.cmd; Add.cmd ]
