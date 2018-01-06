open Core

(* TODO use templates *)

(** Location of the template directory *)
let template_dir : string ref = ref ""

type failure_reason =
  | Directory_exists of string
  | File_not_found of string
  | File_exists of string

type 'a result = ('a, failure_reason) Result.t

type kind =
  | Executable
  | Library
[@@deriving show]

let name_regexp = Str.regexp_string "%%NAME%%"

(* - dir name
    - file name.opam
    - dir bin|lib:
     - name.ml
     - jbuild
    - dir test
     - name_test.ml
     - jbuild *)

let lib_jbuild name =
  Printf.sprintf "(jbuild_version 1)

(library
 ((name      %s)
  (public_name %s)
  (synopsis  \"\")
  (libraries (core))
  (preprocess (pps (ppx_deriving.std)))))
"
    name name

let test_jbuild name =
  Printf.sprintf "(jbuild_version 1)

(executable
 ((name       test_%s)
  (public_name test_%s)
  (libraries  (qcheck %s))))

(alias
 ((name runtest)
  (deps (test_%s.exe))
  (action (run ${<}))))
"
    name name name name

exception Not_implemented

let new_tests
  : string -> unit
  = fun name ->
    Unix.( mkdir "test"
         ; chdir "test"
         ; Out_channel.write_lines ("test_" ^ name ^ ".ml") []
         ; Out_channel.write_all "jbuild" ~data:(test_jbuild name))

let new_executable
  : string -> unit
  = fun _ -> raise Not_implemented

let new_library
  : string -> unit
  = fun name ->
    Unix.( let base_dir = Filename.concat (getcwd ()) name
           in mkdir base_dir
            ; chdir base_dir
            ; Out_channel.write_lines (name ^ ".opam") []
            ; mkdir "lib"
            ; chdir "lib"
            ; Out_channel.write_lines (name ^ ".ml") []
            ; Out_channel.write_all "jbuild" ~data:(lib_jbuild name)
            ; chdir base_dir
            ; new_tests name)

let new_project
  : kind -> string -> unit
  = function
    | Executable -> new_executable
    | Library    -> new_library

let substitute_name_in_template_string
  : name:string -> string -> string
  = fun ~name string ->
    Str.global_replace name_regexp name string

let substitute_name_in_template_file
  : name:string -> string -> unit result
  = fun ~name file_name ->
    try
      let data =
        file_name
        |> In_channel.read_all
        |> substitute_name_in_template_string ~name
      in
      Ok (Out_channel.write_all file_name ~data)
    with
    | Sys_error err -> Error (File_not_found err)

(** [make_project_dir name] is the the absolute path path to the directory
    created for project [name] project directory. Unless a [~location] is
    specified, the project directory is created in the current working
    directory. *)
let make_project_dir
  : ?location:string -> string -> string result
  = fun ?location name ->
    let location = Option.value location ~default:(Unix.getcwd ()) in
    let base_dir = Filename.concat location name in
    match Unix.mkdir base_dir with
    | () ->
      Ok base_dir
    | exception Unix.(Unix_error (EEXIST, _, _)) ->
      Error (Directory_exists base_dir)

let copy_template_to_dir
  : template:string -> string -> string result
  = fun ~template project_dir ->
    try
      let contents = FileUtil.ls template in
      let () = FileUtil.cp ~recurse:true contents project_dir in
      Ok project_dir
    with
    | Sys_error err -> Error (File_not_found err)

let rename_template_files
  : name:string -> string -> string list result
  = fun ~name project_dir ->
    let template_file_names =
      Aux.dir_contents project_dir
    in
    let project_file_names =
      let f = substitute_name_in_template_string ~name in
      List.map ~f template_file_names
    in
    try
      ignore @@ List.map2 ~f:FileUtil.mv template_file_names project_file_names;
      Ok project_file_names
    with
    | FileUtil.RmError err -> Error (File_exists err)
    | FileUtil.MvError err -> Error (File_not_found err)

let substitute_name_in_template_files
  : name:string -> string list -> unit result
  = fun ~name project_file_names ->
    let f = substitute_name_in_template_file ~name in
    List.map ~f project_file_names |> Result.all_ignore

let make_project_from_template
  : ?location:string -> template:string -> string -> unit result
  = fun ?location ~template name ->
    let open Result.Monad_infix in
    make_project_dir ?location name
    >>= copy_template_to_dir ~template
    >>= rename_template_files ~name
    >>= substitute_name_in_template_files ~name
