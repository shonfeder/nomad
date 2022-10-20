(* open Bos *)
open Sexplib.Type

let load_dune_project project_file =
  Bos.OS.File.with_ic project_file (fun ic () -> Sexplib.Sexp.input_sexps ic) ()

(* map over the cells following the field [field] *)
let rec map_field field f = function
  | List (Atom n :: rest) when n = field -> List (Atom n :: f rest)
  | List elems -> List (List.map (map_field field f) elems)
  | sexp -> sexp

(* Map on the expresion labeled with [field] from the list of expressions [exps] *)
let map_expr field f exps =
  match map_field field f (List exps) with
  | List exps' -> exps'
  | _ -> failwith "impossible"

let dep (d, v) =
  match v with
  | None -> Atom d
  | Some v -> List [ Atom d; List [ Atom "="; Atom v ] ]

let add_unique_deps new_deps deps =
  let rec add_dep deps (d, v) =
    match deps with
    | Atom f :: rest when f = d -> dep (d, v) :: rest
    | List (Atom f :: _) :: rest when f = d ->
        if Option.is_none v then
          deps
        else
          dep (d, v) :: rest
    | a :: rest -> a :: add_dep rest (d, v)
    | [] -> [ dep (d, v) ]
  in
  List.fold_left add_dep deps new_deps

let add_deps_to_sexp (deps : (string * string option) list) (sexps : t list) =
  List.map (map_field "depends" (add_unique_deps deps)) sexps

let save_dune_project project_file sexps =
  Sexplib.Sexp.save_sexps_hum (Fpath.to_string project_file) sexps;
  Ok ()

let add_deps root deps =
  let open Result.Let in
  match deps with
  | [] -> Ok ()
  | deps ->
      let project_file = Fpath.(root / "dune-project") in
      let* dune_project = load_dune_project project_file in
      dune_project
      |> map_expr "package" (add_deps_to_sexp deps)
      |> save_dune_project project_file
