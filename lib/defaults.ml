(** Default content *)

(*** Default ocamlformat file *)
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
