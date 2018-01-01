open Core
open QCheck
open Nomad

let () = Unix.chdir "../bin"
let () = print_endline @@ Unix.getcwd ()
let template_dir = Filename.realpath "../templates"
let () = Project.template_dir := template_dir

let tests = [
  Test.make ~name:"copy template test"
    ~count:1
    unit
    begin
      fun () ->
        Result.is_ok @@
        Project.make_project_from_template
          ~location:"/Users/sf/Dropbox/Programming/ocaml/nomad"
          "testing"
          "/Users/sf/Dropbox/Programming/ocaml/nomad/templates/lib"
    end
]

let () = QCheck_runner.run_tests_main tests
