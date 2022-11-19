open! Bos

type config =
  { name : string
  ; kind : Project.Kind.t
  }

let switch_plate_url = "https://gitlab.com/shonfeder/switch-plate.git"

(* Create an opam switch *)
let run : Common.t -> config -> (unit, string) result =
 fun { config; _ } { name; kind } ->
  Result.of_rresult
  @@
  let open Result.Let in
  let* () = Dune_cmd.init name kind in
  (* Add config files *)
  let dir = Fpath.v name in
  let* () = Add.dune_project ~dir ~name config () in
  let* () = Add.gitignore ~dir () in
  let* () = Add.ocamlformat ~dir () in
  (* Enter project dir and set up *)
  let* () = OS.Dir.set_current dir in
  let* () = Git_cmd.init () in
  let* () = Git_cmd.add [ "." ] in
  let+ () = Git_cmd.commit "Initiate project" in
  ()
