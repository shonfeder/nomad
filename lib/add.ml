(* TODO Support configuring the components*)
type components =
  { ocamlformat : bool
  ; dune_project : string option
  ; gitignore : bool (* TODO Infer name from project *)
  ; opam_template : string option
  ; deps : (string * string option) list
  }

let ocamlformat ?dir () = Defaults.ocamlformat ?dir () |> File.write

let dune_project ?(dir = Fpath.v ".") ~name config () =
  let open Result.Let in
  let* f = Defaults.dune_project ~dir ~name config in
  File.write f

let gitignore ?(dir = Fpath.v ".") () = Defaults.gitignore ~dir () |> File.write

let opam_template ~name ?dir () =
  Defaults.opam_template ~name ?dir () |> File.write

let add_if bool f =
  if bool then
    f ()
  else
    Ok ()

(* TODO Find the project root to work from as default location *)
let run (opts : Common.t) components =
  Result.of_rresult
  @@
  let root = Fpath.v "." in
  (* TODO *)
  let open Result.Let in
  let* () = Dune_config.add_deps root components.deps in
  let* () = add_if components.ocamlformat ocamlformat in
  let* () = add_if components.gitignore gitignore in
  let* () =
    match components.opam_template with
    | None -> Ok ()
    | Some name -> opam_template ~name ()
  in
  let+ () =
    match components.dune_project with
    | None -> Ok ()
    | Some name -> dune_project ~name opts.config ()
  in
  ()
