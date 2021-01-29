(* TODO Support configuring the components*)
type config = { ocamlformat : bool }

(* TODO Find the project root to work from *)
let run _opts { ocamlformat } =
  if ocamlformat then
    File.write Defaults.ocamlformat
  else
    Ok ()
