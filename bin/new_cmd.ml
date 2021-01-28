open Nomad.New_project
open Kwdcmd

let cmd =
  cmd ~name:"new" ~doc:"begin a new project"
  @@ let+ name =
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
     run { name; kind }
