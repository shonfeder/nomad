open! Bos

type config =
  { name : string
  ; kind : Project.Kind.t
  }

(* Create an opam switch *)
let run : Common.t -> config -> (unit, Rresult.R.msg) result =
 fun ({ config; _ } as opts) { name; kind } ->
  let open Result.Let in
  let* () = Dune_cmd.init name kind in
  let dir = Fpath.v name in
  let* () = Add.dune_project ~dir ~name config () in
  let* () = Add.gitignore ~dir () in
  let* () = Add.ocamlformat ~dir () in
  let* () = OS.Dir.set_current dir in
  let* () = Opam_cmd.create_switch () in
  let+ () = Sync.run opts in
  ()
