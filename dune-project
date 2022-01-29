(lang dune 2.9)
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
   ; TODO pin to versions
   bos
   re
   kwdcmd                       ; TODO add as pin dep
   ppx_string
   sexplib
  ; Tests
  (alcotest :with-test)
  (qcheck :with-test)
  (qcheck-alcotest :with-test)
))
