Create an empty config to avoid searching into the runner environments file system
  $ mkdir .nomad && echo "()" > .nomad/config.sexp

Add a new ocamlformat file
  $ nomad add --ocamlformat
  $ cat .ocamlformat
  exp-grouping = preserve
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
