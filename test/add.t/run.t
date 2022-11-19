Create an empty config to avoid searching into the runner environments file system
  $ mkdir .nomad && echo "()" > .nomad/config.sexp

Add a new ocamlformat file
  $ nomad add --ocamlformat
  $ cat .ocamlformat
  exp-grouping = preserve
  break-fun-sig = fit-or-vertical
  break-fun-decl = fit-or-vertical
  wrap-fun-args = false
  dock-collection-brackets = false
  align-cases = true
  break-cases = all
  break-separators = before
  break-infix = fit-or-vertical
  if-then-else = k-r
  nested-match = align
  type-decl = sparse

TODO: Automatically create the file?
Adding a dep with no dune-project errors
  $ nomad add nodep
  nomad: ./dune-project: No such file or directory
  [123]

Add add a new dune-project file
  $ nomad add --dune-project=test_proj
  $ test -f dune-project

Adding a new dep with no version to the project
  $ nomad add dep-with-no-version
  $ cat dune-project
  (lang dune 2.9)
  (cram enable)
  (generate_opam_files true)
  (name test_proj)
  (license MIT)
  (authors "Author Name")
  (maintainers "Author Name")
  (source (github github-username/test_proj))
  (package (name test_proj) (synopsis "Short description")
   (description "Longer description")
   (depends (dune (> 2.9)) ocaml (alcotest :with-test) (qcheck :with-test)
    (qcheck-alcotest :with-test) dep-with-no-version))

Duplicates dependencies are not added
  $ nomad add dep-with-no-version
  $ cat dune-project
  (lang dune 2.9)
  (cram enable)
  (generate_opam_files true)
  (name test_proj)
  (license MIT)
  (authors "Author Name")
  (maintainers "Author Name")
  (source (github github-username/test_proj))
  (package (name test_proj) (synopsis "Short description")
   (description "Longer description")
   (depends (dune (> 2.9)) ocaml (alcotest :with-test) (qcheck :with-test)
    (qcheck-alcotest :with-test) dep-with-no-version))

Add a dep with version
  $ nomad add dep-with-version=1.0.0
  $ cat dune-project
  (lang dune 2.9)
  (cram enable)
  (generate_opam_files true)
  (name test_proj)
  (license MIT)
  (authors "Author Name")
  (maintainers "Author Name")
  (source (github github-username/test_proj))
  (package (name test_proj) (synopsis "Short description")
   (description "Longer description")
   (depends (dune (> 2.9)) ocaml (alcotest :with-test) (qcheck :with-test)
    (qcheck-alcotest :with-test) dep-with-no-version
    (dep-with-version (= 1.0.0))))

Adding a dep with version replaces dep without a version
  $ nomad add dep-with-no-version=1.0.0
  $ cat dune-project
  (lang dune 2.9)
  (cram enable)
  (generate_opam_files true)
  (name test_proj)
  (license MIT)
  (authors "Author Name")
  (maintainers "Author Name")
  (source (github github-username/test_proj))
  (package (name test_proj) (synopsis "Short description")
   (description "Longer description")
   (depends (dune (> 2.9)) ocaml (alcotest :with-test) (qcheck :with-test)
    (qcheck-alcotest :with-test) (dep-with-no-version (= 1.0.0))
    (dep-with-version (= 1.0.0))))

Add a dep with a custom dune_project

  $ cat << EOF > custom-dune-project.sexp
  > ; My custom dune-project file
  > (name \$(NAME))
  > (license MIT)
  > (authors "\$(AUTHOR)")
  > (maintainers "\$(AUTHOR)")
  > (source (github \$(USERNAME)/\$(NAME)))
  > EOF

And configure that for use

  $ echo '((author "Author Name") (username github-username) (dune_project custom-dune-project.sexp))' > config.sexp

checking that we can load our custom config

  $ nomad config --config config.sexp
  ((author "Author Name") (username github-username)
    (dune_project custom-dune-project.sexp)
    (dev_packages
      (merlin>=4.6.1~5.0preview utop ocp-indent ocp-index odoc odig)))

Now add a new dune-project using that custom config

  $ nomad add --config config.sexp --dune-project=custom_dune_proj
  $ cat dune-project
  ; My custom dune-project file
  (name custom_dune_proj)
  (license MIT)
  (authors "Author Name")
  (maintainers "Author Name")
  (source (github github-username/custom_dune_proj))
