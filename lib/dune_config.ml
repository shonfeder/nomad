let add_deps deps =
  print_endline "We are to add deps!";
  List.iter (fun (d, _) -> print_endline d) deps
