open! Bos

type config =
  { name : string
  ; kind : Project.Kind.t
  }

(** TODO use ppx_fields_conv *)
let make ~name ~kind () = { name; kind }

let ( let* ) = Result.bind

(* TODO  *)
let run : Common.t -> config -> (unit, Rresult.R.msg) result =
 (* TODO add .gitignore *)
 (* TODO add .ocamlformat *)
 (* TODO add .populate dune-project *)
  (* fun opts {name = _; kind = _} -> *)
  fun _opts {name; kind} ->
  let* res = Dune_cmd.init name kind in
  Ok (ignore res)





  (* match kind with
   *  | Library -> *)
