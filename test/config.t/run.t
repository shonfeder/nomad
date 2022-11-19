Create an empty config to avoid searching into the runner environments file system

  $ mkdir .nomad && echo "()" > .nomad/config.sexp

When no config values are specified, use the nearest config dir

  $ nomad config
  ((author "Author Name") (username github-username)
    (dev_packages
      (merlin>=4.6.1~5.0preview utop ocp-indent ocp-index odoc odig)))

Can read config overrides from the nearest config dir

  $ echo '((author "Test Name") (username test-username))' > .nomad/config.sexp
  $ nomad config
  ((author "Test Name") (username test-username)
    (dev_packages
      (merlin>=4.6.1~5.0preview utop ocp-indent ocp-index odoc odig)))

Can load explicitly set config

  $ cat <<EOF > config.sexp
  > ((author foo)
  >  (username user-foo)
  >  (dev_packages (owl))
  > )
  > EOF
  $ nomad config --config config.sexp
  ((author foo) (username user-foo) (dev_packages (owl)))

Default values are supplied when config has missing fields

  $ echo "()" > config.sexp
  $ nomad config --config config.sexp
  ((author "Author Name") (username github-username)
    (dev_packages
      (merlin>=4.6.1~5.0preview utop ocp-indent ocp-index odoc odig)))

When config file supplied by CLI is not found, report error

  $ nomad config --config non-existent-file.sexp
  nomad: Config file non-existent-file.sexp does not exist
  [123]
