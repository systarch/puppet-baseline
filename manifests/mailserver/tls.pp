# @summary
#   Ensure the postfix mailserver is configured to use TLS transport when receiving/sending mail
#
class baseline::mailserver::tls {
  [ $ensure_ssl, $privkey, $fullchain ] = baseline::get_server_certificate($baseline::fqdn)

  # configure postfix to use letsencrypt certificates for TLS communication
  postfix::config { 'smtpd_tls_cert_file':
    ensure => present,
    value  => $fullchain,
  }
  postfix::config { 'smtpd_tls_key_file':
    ensure => present,
    value  => $privkey,
  }

  #starting with postfix3.4, this can be improved to:
  #postfix::config { 'smtpd_tls_chain_files':
  #  ensure => $ensure_ssl,
  #  value  => "${privkey}, ${fullchain}",
  #}


  postfix::config { 'smtpd_use_tls':
    ensure => $ensure_ssl,
    value  => 'yes',
  }

  postfix::config { 'smtp_tls_CAfile':
    ensure => $ensure_ssl,
    value  => '/etc/ssl/certs/ca-certificates.crt',
  }

  postfix::config { 'smtp_tls_loglevel':
    ensure => $ensure_ssl,
    value  => '1',
  }

  postfix::config { 'smtp_tls_security_level':
    ensure => $ensure_ssl,
    value  => 'may',
  }

}