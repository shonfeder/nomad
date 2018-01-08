open Core
open QCheck
open Nomad

let () = Unix.chdir "../bin"
let () = print_endline @@ Unix.getcwd ()
let template_dir = Filename.realpath "../templates"

let tests =
  [

    Test.make
      (* TODO how to mock? *)
      ~name:"make new project"
      ~count:1
      unit
      begin
        fun () ->
          Result.is_ok @@
          Project.make_project_from_template
            ~location:"/Users/sf/Dropbox/Programming/ocaml/nomad"
            ~template:"/Users/sf/Dropbox/Programming/ocaml/nomad/templates/lib"
            "project-test"
      end;

    Test.make
      ~name:"substitute_name_in_template_string replaces any instance of %%NAME%%"
      (pair small_string (small_list (oneof [printable_string; always "%%NAME%%"])))
      begin fun (to_substitute, string_parts) ->
        assume (String.length to_substitute > 0);
        (* TODO Find way to make condition unnecessary? *)
        assume (not @@ Str.string_match
                  (Str.regexp_string to_substitute) "%%NAME%%" 0);
        let string = String.concat string_parts in
        let num_existing_ocurrances =
          Aux.count_matches to_substitute string in
        let num_name_instaces =
          List.length @@ List.filter string_parts ~f:(fun x -> x = "%%NAME%%") in
        let substituted =
          Project.substitute_name_in_template_string ~name:to_substitute string
        in
        let num_after_substitution =
          Aux.count_matches to_substitute substituted in
        let num_expected_substiutions =
          num_after_substitution - num_existing_ocurrances in
        num_expected_substiutions = num_name_instaces ||
        (Printf.printf "failed on %s" substituted; false)
      end;

    Test.make
      ~name:"dir_contents lists file contents recursively"
      ~count:1
      unit
      begin fun () ->
        let files = Aux.dir_contents @@ Filename.concat template_dir "lib" in
        (*XXX*)
        files = ["/Users/sf/Dropbox/Programming/ocaml/nomad/_build/default/templates/lib/%%NAME%%.opam";
                "/Users/sf/Dropbox/Programming/ocaml/nomad/_build/default/templates/lib/src/%%NAME%%.ml";
                "/Users/sf/Dropbox/Programming/ocaml/nomad/_build/default/templates/lib/src/jbuild";
                "/Users/sf/Dropbox/Programming/ocaml/nomad/_build/default/templates/lib/test/jbuild";
                "/Users/sf/Dropbox/Programming/ocaml/nomad/_build/default/templates/lib/test/tests.ml"
               ]
        (* print_endline ([%derive.show: string list] files);
         * true *)
      end;

  ]

let () = QCheck_runner.run_tests_main tests
