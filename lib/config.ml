(* Config file loading *)

open Bos
open Sexplib.Std

let dev_dep_defaults =
  [ "merlin>=4.6.1~5.0preview" (*  OCaml 5 compat *)
  ; "ocaml-lsp-server"
  ; "utop"
  ; "ocp-indent"
  ; "ocp-index"
  ; "odoc"
  ; "odig"
  ]

type t =
  { author : string [@default "Author Name"]
  ; username : string [@default "github-username"]
  ; dune_project : string option [@sexp.option]
  ; dev_packages : string list [@sepx.option] [@default dev_dep_defaults]
  }
[@@deriving sexp]

let default = Sexplib.Sexp.List [] |> t_of_sexp

let load_from_file fpath =
  Logs.debug (fun f -> f "Loading config from file %a" Fpath.pp fpath);
  match OS.File.exists fpath with
  | Error _
  | Ok false ->
      Error
        (Printf.sprintf "Config file %s does not exist" (Fpath.to_string fpath))
  | Ok true -> (
      let config_file = Fpath.to_string fpath in
      try Ok (Sexplib.Sexp.load_sexp_conv_exn config_file t_of_sexp) with
      | Sexplib.Conv_error.Of_sexp_error (exn, sexp) ->
          Error (Sexplib.Conv.of_sexp_error_exn exn sexp))

let is_config_dir dir = String.equal (Fpath.basename dir) ".nomad"

let find_nearest_config () =
  Result.of_rresult
  @@
  let open Result.Let in
  let rec search dir =
    let* contents = OS.Dir.contents ~dotfiles:true dir in
    match List.find_opt is_config_dir contents with
    | None when Fpath.is_root dir -> Ok None
    | Some f -> Ok (Some f)
    | None -> search (Fpath.parent dir)
  in
  let* cwd = OS.Dir.current () in
  search cwd

let load : Fpath.t option -> (t, string) Rresult.result =
 fun config_file ->
  let open Result.Let in
  match config_file with
  | Some f -> load_from_file f
  | None -> (
      let* config_dir = find_nearest_config () in
      match config_dir with
      | None ->
          Logs.warn (fun f ->
              f "Cannot find nomad config dir, using default config");
          Ok default
      | Some config_dir -> (
          let result = load_from_file Fpath.(config_dir / "config.sexp") in
          match result with
          | Error _ ->
              Logs.warn (fun f ->
                  f "No config file in config dir %a" Fpath.pp config_dir);
              Ok default
          | Ok _ -> result))
