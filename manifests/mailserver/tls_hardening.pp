#
# @summary
#   Recommended settings from https://kruyt.org/postfix-and-tls-encryption/
#
class baseline::mailserver::tls_hardening {
  # Disable SSL,TLSv1, TLSv1.1
  postfix::config { 'smtpd_tls_protocols':
    ensure => present,
    value  => 'TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv2, !SSLv3',
  }
  postfix::config { 'smtp_tls_protocols':
    ensure => present,
    value  => 'TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv2, !SSLv3',
  }
  postfix::config { 'smtp_tls_ciphers':
    ensure => present,
    value  => 'high',
  }
  postfix::config { 'smtpd_tls_ciphers':
    ensure => present,
    value  => 'high',
  }
  postfix::config { 'smtpd_tls_mandatory_protocols':
    ensure => present,
    value  => 'TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv2, !SSLv3',
  }
  postfix::config { 'smtp_tls_mandatory_protocols':
    ensure => present,
    value  => 'TLSv1.3, TLSv1.2, !TLSv1.1, !TLSv1, !SSLv2, !SSLv3',
  }
  postfix::config { 'smtp_tls_mandatory_ciphers':
    ensure => present,
    value  => 'high',
  }
  postfix::config { 'smtpd_tls_mandatory_ciphers':
    ensure => present,
    value  => 'high',
  }

  # Disable deprecated ciphers
  postfix::config { 'tls_high_cipherlist':
    ensure => present,
    value  => '!aNULL:!eNULL:!CAMELLIA:HIGH:@STRENGTH',
  }
  postfix::config { 'tls_preempt_cipherlist':
    ensure => present,
    value  => 'yes',
  }

  postfix::config { 'tls_ssl_options':
    ensure => present,
    value  => 'NO_RENEGOTIATION',
  }


}