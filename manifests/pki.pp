class baseline::pki {

  exec { "Create .well-known directory for returning ACME challenges":
    command => "/bin/mkdir -p '${baseline::webserver_wellknown_dir}'",
    creates => $baseline::webserver_wellknown_dir,
  }

  ensure_resources('baseline::certificate', $baseline::certificates)
}