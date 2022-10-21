Create an empty config to avoid searching into the runner environments file system
  $ mkdir .nomad && echo "()" > .nomad/config.sexp

When no config file is specified, use the nearest config dir

  $ nomad config
  ((author "Author Name") (username github-username))

Can read data from the nearest config dir

  $ echo '((author "Test Name") (username test-username))' > .nomad/config.sexp
  $ nomad config
  ((author "Test Name") (username test-username))

Can load explicitly set config

  $ echo "
  > ((author foo)
  >  (username user-foo))" > config.sexp
  $ nomad config --config config.sexp
  ((author foo) (username user-foo))

Default values are supplied when config has missing fields

  $ echo "()" > config.sexp
  $ nomad config --config config.sexp
  ((author "Author Name") (username github-username))

When config file supplied by CLI is not found, report error

  $ nomad config --config non-existent-file.sexp
  nomad: Config file non-existent-file.sexp does not exist
  [123]
