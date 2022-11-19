(** Default content *)

(** Default ocamlformat file *)
let ocamlformat ?(dir = Fpath.v ".") () : File.t =
  let path = Fpath.(dir / ".ocamlformat") in
  let content =
    {|exp-grouping = preserve
break-fun-sig = fit-or-vertical
break-fun-decl = fit-or-vertical
wrap-fun-args = false
dock-collection-brackets = false
align-cases = true
break-cases = all
break-separators = before
break-infix = fit-or-vertical
if-then-else = k-r
nested-match = align
type-decl = sparse
|}
  in
  { path; content }

let default_dune_project ~name ~author ~username =
  let dune_version = "2.9" in
  [%string
    {|(lang dune $(dune_version))
(cram enable)
(generate_opam_files true)

(name $name)
(license MIT)
(authors "$author")
(maintainers "$author")
(source (github $username/$name))

(package
 (name $name)
 (synopsis "Short description")
 (description "Longer description")
 (depends
  (dune (> $dune_version))
  ocaml
  (alcotest :with-test)
  (qcheck :with-test)
  (qcheck-alcotest :with-test)
))
|}]

let dune_project ~dir ~name ({ author; username; dune_project; _ } : Config.t) : (File.t, Rresult.R.msg) Result.t =
  let open Result.Let in
  let+ content = match dune_project with
    | None -> Ok (default_dune_project ~name ~author ~username)
    | Some path ->
      let open Bos in
      let* content = Bos.OS.File.read Fpath.(v path) in
      let+ pat = Pat.of_string content in
      let defs = Astring.String.Map.(
          empty
          |> add "NAME" name
          |> add "USERNAME" username
          |> add "AUTHOR" author
        )
      in
      Pat.format defs pat
  in
  let path = Fpath.(dir / "dune-project") in
  File.{ path; content }

let gitignore ?(dir = Fpath.v ".") () : File.t =
  let path = Fpath.(dir / ".gitignore") in
  let content =
    {|
# Dune build directory
_build/
# Opam switch directory
_opam/
|}
  in
  { path; content }

let opam_template ~name ?(dir = Fpath.v ".") () : File.t =
  let path = Fpath.(dir / [%string {|$(name).opam.template|}]) in
  let content =
    {|pin-depends: [
  ["{package}.dev" "git+https://{forge}/{username}/{repo}.git"]
]
|}
  in
  { path; content }
