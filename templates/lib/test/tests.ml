open Core
open QCheck

let tests = [
  Test.make ~name:"name of test"
    ~count:10_000 ~max_fail:3
    (list small_nat)
    (fun l -> l = List.rev (List.rev l))
]

let () = QCheck_runner.run_tests_main tests
