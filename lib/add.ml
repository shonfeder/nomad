(* TODO Support configuring the components*)
type config = { ocamlformat : bool; dune_project : string option; gitignore : bool }

let ocamlformat ?dir () = Defaults.ocamlformat ?dir () |> File.write

let dune_project ?(dir = Fpath.v ".") ~name config () =
  Defaults.dune_project ~dir ~name config |> File.write

let gitignore ?(dir = Fpath.v ".") () =
  Defaults.gitignore ~dir () |> File.write

let add_if bool f = if bool then f () else Ok ()

(* TODO Find the project root to work from as default locatio n*)
let run (opts : Common.t) components =
  let open Result.Let in
  let* () = add_if components.ocamlformat ocamlformat in
  let* () = add_if components.gitignore gitignore in
  let+ () =
    match components.dune_project with
    | None -> Ok ()
    | Some name -> dune_project ~name opts.config ()
  in
  ()
