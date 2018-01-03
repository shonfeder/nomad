open Core
open QCheck
open Nomad

let () = Unix.chdir "../bin"
let () = print_endline @@ Unix.getcwd ()
let template_dir = Filename.realpath "../templates"
let () = Project.template_dir := template_dir

let tests =
  [

    (* Test.make
     * TODO how to mock?
     *   ~name:"copy template test"
     *   ~count:1
     *   unit
     *   begin
     *     fun () ->
     *       Result.is_ok @@
     *       Project.make_project_from_template
     *         ~location:"/Users/sf/Dropbox/Programming/ocaml/nomad"
     *         "project-test"
     *         "/Users/sf/Dropbox/Programming/ocaml/nomad/templates/lib"
     *   end; *)

    Test.make
      ~name:"substitue_name_in_template_string replaces any instance of %%NAME%%"
      (* ~count:1 *)
      (small_list (oneof [printable_string; always "%%NAME%%"]))
      begin fun string_parts ->
        let string = String.concat string_parts in
        let res = Project.substitute_name_in_template_string ~name:"dingo" string
        (** TODO *)
        in print_endline res ; true
      end

  ]

let () = QCheck_runner.run_tests_main tests
