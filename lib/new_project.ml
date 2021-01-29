module Kind = struct
  type t =
    | Library
    | Binary
end

type config =
  { name : string
  ; kind : Kind.t
  }

(** TODO use ppx_fields_conv *)
let make ~name ~kind () = { name; kind }

(* TODO  *)
let run : Common.t -> config -> (unit, Rresult.R.msg) result =
 (* TODO add .gitignore *)
 (* TODO add .ocamlformat *)
 (* TODO add .populate dune-project *)
 fun _opts _ -> raise (Failure "TODO")
