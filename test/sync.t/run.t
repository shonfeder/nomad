Create an empty config to avoid searching into the runner environments file system

  $ mkdir .nomad && echo "()" > .nomad/config.sexp

Initialize new project

  $ nomad new --bin new_project | grep -o "Initiate project"
  Initiate project

CD into the new project

  $ cd new_project

Can sync the dependencies

  $ nomad sync | grep -o Done.
  Done.
  Done.
  Done.

We can build the tests

  $ dune test
