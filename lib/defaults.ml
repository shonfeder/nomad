(** Default content *)

(** Default ocamlformat file *)
let ocamlformat : File.t =
  let path = Fpath.v ".ocamlformat" in
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

(*
Bos.Pat
let dune_project : name:string -> File.t =
  fun ~name:_ ->
  {|(lang dune 2.9)
(cram enable)
(generate_opam_files true)

(name nomad)
(license MIT)
(authors "Shon Feder")
(maintainers "TODO")
(source (github shonfeder/nomad))

(package
 (name nomad)
 (synopsis "Portable Habitations in OCaml's Dunes")
 (description "
A tiny, minimally functional project launcher (maybe more general
utility) for OCaml, coordinating [[https://github.com/ocaml/dune][Dune]], opam,
and other tooling in the ecosystem.
")
 (depends
  (dune (> 2.7))
  (mdx :build)
  (ocaml (>= 4.13))
  (alcotest :with-test)
   ; TODO pin to versions
   bos
   re
   kwdcmd                       ; TODO add as pin dep
  (qcheck :with-test)
  (qcheck-alcotest :with-test)
))
|}
*)
