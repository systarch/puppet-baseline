# @summary
#   Ensures the postfix mailserver that delivers mail directly is configured with a valid OpenDKIM keypair
#
class baseline::mailserver::opendkim {

  if ($baseline::postfix_relayhost == 'direct' or $baseline::postfix_relayhost == 'relay') {
    $ensure = present
    $ensure_package = latest
    $ensure_service = running
    $enable_service = true
  } else {
    $ensure = absent
    $ensure_package = absent
    $ensure_service = stopped
    $enable_service = false
  }

  # Automatically create a dkim-key if none is present and we need one
  if $ensure == 'present' {
    exec { 'Automatically create a dkimkey if none exists':
      command => "/usr/bin/opendkim-genkey -s '${baseline::opendkim_selector}' -d '${baseline::domain}'",
      cwd     => '/etc/opendkim/keys',
      umask   => '0077',
      creates => [
        "/etc/opendkim/keys/${baseline::opendkim_selector}.txt",
        "/etc/opendkim/keys/${baseline::opendkim_selector}.private",
      ],
      require => Package['opendkim-tools'],
    }
  }


  # ----< configure milter to verify/sign mail >----
  # Make sure we accept mail even if opendkim is failing
  postfix::config { 'milter_default_action':
    ensure => $ensure,
    value  => 'accept',
  }

  postfix::config { 'milter_protocol':
    ensure => $ensure,
    value  => '6',
  }

  postfix::config { 'smtpd_milters':
    ensure => $ensure,
    value  => 'inet:127.0.0.1:8891',
  }

  postfix::config { 'non_smtpd_milters':
    ensure => $ensure,
    value  => 'inet:127.0.0.1:8891',
  }

  package { ['opendkim', 'opendkim-tools']:
    ensure => $ensure_package,
    notify => Service['opendkim'],
  }

  if $ensure==present {
    file { ['/etc/opendkim', '/etc/opendkim/keys']:
      ensure => directory,
      owner  => root,
      group  => opendkim,
      mode   => '0750',
    }
  }

  $opendkim_domain_list = $baseline::opendkim_domains.join(', ')
  file { '/etc/opendkim.conf':
    ensure  => $ensure,
    owner   => root,
    group   => opendkim,
    mode    => '0440',
    content => template('baseline/mailserver.opendkim.conf.erb'),
    notify  =>     Service['opendkim'],
  }

  file { '/etc/opendkim/trusted':
    ensure  => $ensure,
    owner   => root,
    group   => opendkim,
    mode    => '0440',
    content => "# File /etc/opendkim/trusted is managed by PUPPET\n127.0.0.1\n::1\nlocalhost\n",
    notify  => Service['opendkim'],
  }

  service { 'opendkim':
    ensure => $ensure_service,
    enable => $enable_service,
  }

  # Warn if the configured dkim key is not yet published on the DNS!
  if $ensure == 'present' {
    $baseline::opendkim_domains.each |$opendkim_domain| {
      $result = baseline::opendkim_testkey($baseline::opendkim_selector, $opendkim_domain)
      if $result != '' {
        err($result)
      }
    }
  }
}