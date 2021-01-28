(* TODO *)
open Bos

module Git = struct
  let bin = Cmd.v "git"

  let add_updated = Cmd.(bin % "--update" % ".")

  let commit msg = Cmd.(bin % "commit" % "-m" % msg)
end

module Dune = struct
  let bin = Cmd.v "dune"

  (* TODO find the root first *)
  let build = Cmd.(bin % "build")
end

module Opam = struct
  let bin = Cmd.v "opam"

  let install_deps = Cmd.(bin % "install" % "." % "--deps-only" % "--with-test")
end

let ( let* ) = Rresult.( >>= )

(** TODO add support for common opts *)
let run () =
  let open OS in
  let* _ =
    (* TODO log error if build fails, but continue, since we still want to sync) *)
    Cmd.run Dune.build
    |> Rresult.R.kignore_error ~use:(fun _ ->
           print_endline "Build failed";
           Ok ())
  in
  let* _ = Cmd.run Git.add_updated in
  let* _ = Cmd.run Git.(commit "Update dependencies") in
  let* _ = Cmd.run Opam.install_deps in
  Cmd.run Dune.build
