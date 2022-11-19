Create an empty config to avoid searching into the runner environments file system

  $ mkdir .nomad && echo "()" > .nomad/config.sexp

Initialize new project

  $ nomad new --bin new_project | grep -o "Initiate project"
  Initiate project

CD into the new project

  $ cd new_project

Create a light-weight dune-project file

  $ mkdir .nomad
  $ echo '((dune_project ./nomad/custom-dune-project.sexp) (dev_packages ()))' > .nomad/config.sexp
  $ nomad config
  ((author "Author Name") (username github-username)
    (dune_project ./nomad/custom-dune-project.sexp) (dev_packages ()))
  $ cat <<EOF > .nomad/custom-dune-proj.sexp
  > (lang dune 2.9)
  > (name \$(NAME))
  > (license MIT)
  > (authors "\$(AUTHOR)")
  > (maintainers "\$(AUTHOR)")
  > (source (github \$(USERNAME)/\$(NAME)))
  > (package
  >  (name $name)
  >  (synopsis "Short description")
  >  (description "Longer description")
  >  (depends
  >    (dune (> 2.9))
  >    ocaml
  > ))
  > EOF

Can sync the dependencies

  $ nomad sync | grep -o Done.
  Done.
  Done.

Add an unmet library dependency

  $ echo "(library (name new_project) (libraries curly))" > lib/dune
  $ nomad add curly

We should be able to sync it, despite the initial dune build failing due to the missing
library dependency

  $ nomad sync | grep -o Done.
  nomad: [WARNING] dune build failed with unfound library, nomad will now update dependecies
  Done.
