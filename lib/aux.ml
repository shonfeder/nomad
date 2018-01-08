(** Auxiliary functions *)

open Core

(** [count_matches pattern string] is the number of times [pattern] appears
    in [string] (non-overlapping count).

    XXX StackOverlow if given [""] for the pattern *)
let count_matches
    : string -> string -> int
    = fun pattern string ->
      let pattern_len = String.length pattern in
      let regexp = Str.regexp_string pattern in
      if pattern_len > String.length string
      then 0
      else
        let rec count pos acc =
          try
            let pos = Str.search_forward regexp string pos in
            count (pos + pattern_len) (succ acc)
          with Not_found -> acc
        in
        count 0 0

(** [dir_contents file] is a list of all the non-directory files
    contained in [file]. If [file] is a directory, it will recursively
    list the files in [file] and its children directories. If [file] is a
    non-directory (which includes files which may be directories but)
    cannot be identified as such) [dir_contents file] is just [[file]]. *)
let rec dir_contents
  : string -> string list
  = fun file ->
    match Sys.is_directory file with
    | `No | `Unknown -> [file]
    | `Yes           ->
      match FileUtil.ls file with
      | []    -> []
      | f::fs -> dir_contents f @ List.concat_map ~f:dir_contents fs

(*TODO Should this use this approach?
  print_endline (FileUtil.which (Sys.argv.(0)) ^ "/../.." |> Filename.realpath);
  It'd cut down on dependencies *)
let package_share_dir package_name =
  let module F = Filename in
  let pkg_dir = Findlib.default_location () in
  F.of_parts [pkg_dir; "..";  "share"; package_name]
  |> F.realpath
