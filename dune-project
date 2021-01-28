(lang dune 2.7)
(name nomad)

(generate_opam_files true)

; (source (github mirage/ocaml-cohttp))
(license MIT)
(authors "Shon Feder")
(maintainers "TODO")

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
  (alcotest :with-test)
   bos
   ppx_deriving
   kwdcmd                       ; TODO add as pin dep
  (qcheck :with-test)
  (qcheck-alcotest :with-test)
))
