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
    and+ config_file =
      Optional.value
        "CONFIG"
        ~flags:[ "config" ]
        ~doc:"Use the supplied config file (defaults to most proximate .nomad/config.sexp in parent directories, and falling back to ~/.nomad/config.sexp)"
        ~conv:Arg.(some Arg.(conv (Fpath.of_string, Fpath.pp)))
        ~default:None
        ~docs
        ()
    in
    let open Nomad.Result.Let in
    (if debug then Logs.(set_level (Some Debug)));
    let+ config = Nomad.Config.load config_file in
    Nomad.Common.{ debug; config }
end

module Add = struct
  let dep_conv : (string * string option) Arg.conv =
    let parser s =
      Stdlib.String.split_on_char '=' s |> function
      | [] -> failwith "Impossible empty string in CLI arg"
      | [ dep ] -> `Ok (dep, None)
      | [ dep; version ] -> `Ok (dep, Some version)
      | _ -> `Error "Invalid dependency specification"
    in
    let printer = Fmt.(pair string (option string)) in
    (parser, printer)

  let cmd =
    cmd ~name:"add" ~doc:"add components and dependencies"
    @@ let+ opts = Common.opts
       and+ ocamlformat =
         Optional.flag
           ~flags:[ "ocamlformat" ]
           ~doc:"add a .ocamlformat file"
           ()
       and+ gitignore =
         Optional.flag ~flags:[ "gitignore" ] ~doc:"add a gitignore file" ()
       and+ dune_project =
         Optional.value
           "PROJECT_NAME"
           ~flags:[ "dune-project" ]
           ~doc:"add a dune-project file"
           ~conv:Arg.(some string)
           ~default:None
           ()
       and+ opam_template =
         Optional.value
           "PROJECT_NAME"
           ~flags:[ "opam-template" ]
           ~doc:"add an opam.template file"
           ~conv:Arg.(some string)
           ~default:None
           ()
       and+ deps =
         Optional.all_from
           "DEPENDENCIES"
           ~conv:dep_conv
           ~nth:(-1)
           ~doc:
             "dependencies to add, listed as $(b,dep-name) or \
              $(b,dep-name=version)"
           ()
       in
       let open Nomad.Result.Let in
       let* opts in
       Nomad.Add.run
         opts
         { ocamlformat; dune_project; gitignore; opam_template; deps }
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
             [ c ~flags:["bin"] Kind.Binary ~doc:"create an executable binary"
             ; c ~flags:["lib"] Kind.Library ~doc:"create a library"
             ])
       in
       let open Nomad.Result.Let in
       let* opts in
       Nomad.New_project.(run opts { name; kind })
end

module Config = struct
  let cmd =
    cmd ~name:"config" ~doc:"view the application configurations"
    @@ let+ opts = Common.opts in
       let open Nomad.Result.Let in
       let+ opts in
       Sexplib.Sexp.output_hum_indent
         2
         stdout
         (Nomad.Config.sexp_of_t opts.config);
       print_newline ()
end

module Sync = struct
  let cmd =
    cmd ~name:"sync" ~doc:"synchronize dependencies"
    @@ let+ opts = Common.opts in
       let open Nomad.Result.Let in
       let* opts in
       Nomad.Sync.run opts
end

let () =
  Exec.commands
    ~name:"nomad"
    ~version:"%%VERSION%%"
    ~doc:"roam freely, building projects and packages with ease"
    [ New.cmd; Sync.cmd; Add.cmd; Config.cmd ]
