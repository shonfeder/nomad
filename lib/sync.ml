(* TODO *)
open Bos

let dep_spec_file f =
  Pat.(matches (v "dune-project") f || matches (v "$(PACK).opam") f)

let switch_plate_url = "https://gitlab.com/shonfeder/switch-plate.git"

let switch_is_initialized () =
  let open Result.Let in
  let* switch, _ = Opam_cmd.current_switch () in
  let+ cwd = OS.Dir.current () in
  Fpath.(equal (v switch) cwd)

(* TODO add support for common opts *)
(* TODO add logic to run updates on pindeps? *)
let run (opts : Common.t) =
  Result.of_rresult
  @@
  let open Result.Let in
  let* switch_is_created = switch_is_initialized () in
  let* () = if not switch_is_created then
      let* () = Opam_cmd.create_switch () in
      Opam_cmd.install_pkgs opts.config.dev_packages
    else
      Ok ()
  in
  let* _ = Dune_cmd.build () |> Dune_cmd.warn_on_lib_not_found in
  let* () =
    let* files =
      Git_cmd.changed_files ()
      |> Result.map (fun f -> List.filter dep_spec_file f)
    in
    match files with
    | [] -> Ok ()
    | files ->
      let* () = Git_cmd.add files in
      Git_cmd.commit "Update dependencies"
  in
  let* () = Opam_cmd.install_deps () in
  let* _ = Dune_cmd.build () in
  Ok ()
