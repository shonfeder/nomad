open Nomad
open Cmdliner

(* TODO Should be namespaced under "new" subcommand *)
let project_name =
  let doc = "The name of the new project" in
  Arg.(required
       & pos 0 (some string) None
       & info [] ~docv:"NAME" ~doc)

(* TODO Make arg group *)
let project_kind =
  let doc = "Create a library" in
  let library = Project.Library, Arg.info ["lib"] ~doc in
  let doc = "Create an executable" in
  let executable = Project.Executable, Arg.info ["bin"] ~doc in
  Arg.(last &
       vflag_all [Project.Executable] [library; executable])

let new_project_t = Term.(const Project.new_project $ project_kind $ project_name)

let info =
  let doc = "roam freely, building projects and packages with ease" in
  Term.info "nomad" ~version:"%%VERSION%%" ~doc ~exits:Term.default_exits

let () = Term.exit @@ Term.eval (new_project_t, info)
