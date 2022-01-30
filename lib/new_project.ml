open! Bos

type config =
  { name : string
  ; kind : Project.Kind.t
  }

(** TODO use ppx_fields_conv *)
let make ~name ~kind () = { name; kind }

(* TODO  *)
let run : Common.t -> config -> (unit, Rresult.R.msg) result =
 (* TODO add .gitignore *)
 (* TODO add .populate dune-project *)
 (* fun opts {name = _; kind = _} -> *)
 fun { config; _ } { name; kind } ->
  let open Result.Let in
  let* () = Dune_cmd.init name kind in
  let dir = Fpath.v name in
  let* () = Add.dune_project ~dir ~name config () in
  let* () = Add.gitignore ~dir () in
  let+ () = Add.ocamlformat ~dir () in
  ()

(* match kind with
 *  | Library -> *)
