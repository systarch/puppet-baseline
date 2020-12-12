# @summary
#   Ensure mail user agents can access the mailserver via SASL authentication.
#
class baseline::mailserver::sasl_authentication {

  if str2bool($baseline::enable_sasl_auth) {
    $ensure = present
    $ensure_file    = file
    $ensure_package = latest
    $ensure_service = running
    $enable_service = true
  } else {
    $ensure = absent
    $ensure_file = absent
    $ensure_package = absent
    $ensure_service = stopped
    $enable_service = false
  }

  file { '/etc/postfix/sasl/smtpd.conf':
    ensure  => $ensure_file,
    mode    => '0444',
    owner   => root,
    group   => root,
    content => "pwcheck_method: auxprop\nauxprop_plugin: sasldb\nmech_list: PLAIN LOGIN\n",
    notify  => Service['saslauthd'],
  }

  ensure_resource('package', 'libsasl2-modules', {
    ensure => $ensure_package,
  })

  # Tweak the saslauthd service configuration
  if $ensure == present {
    file_line { 'Ensure saslauthd creates socket within postfix chroot':
      path               => '/etc/default/saslauthd',
      match              => '^OPTIONS=',
      line               => 'OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"',
      append_on_no_match => true,
      require            => Package['libsasl2-modules'],
      notify             => Service['saslauthd'],
    }
    file_line { 'Ensure saslauthd uses the sasldb mechanism':
      path               => '/etc/default/saslauthd',
      match              => '^MECHANISMS=',
      line               => 'MECHANISMS="sasldb"',
      append_on_no_match => true,
      require            => Package['libsasl2-modules'],
      notify             => Service['saslauthd'],
    }
  }

  # Keep the sasl_security_options configs around
  postfix::config { 'smtpd_sasl_auth_enable':
    ensure => present,
    value  => 'no', #### bool2str($baseline::enable_sasl_auth, 'yes', 'no'),

  }
  postfix::config { 'smtpd_sasl_security_options':
    ensure => present,
    value  => 'noplaintext noanonymous',
  }
  postfix::config { 'smtpd_sasl_tls_security_options':
    ensure => present,
    value  => 'noanonymous',
  }

  # Required since Debian10?
  postfix::config { 'smtpd_relay_restrictions':
    ensure => present,
    value  => 'permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination',
  }

  if $ensure == present {
    exec {'add postfix to sasl group':
      unless  => '/usr/bin/getent group sasl|/usr/bin/cut -d: -f4|/bin/grep -q postfix',
      command => '/usr/bin/gpasswd -a postfix sasl',
      require => Package['postfix', 'libsasl2-modules'],
      before  => Service['postfix'],
    }
  } else {
    exec {'remove postfix from sasl group':
      onlyif  => '/usr/bin/getent group sasl|/usr/bin/cut -d: -f4|/bin/grep -q postfix',
      command => '/usr/bin/gpasswd -d postfix sasl',
      require => Package['postfix', 'libsasl2-modules'],
      before  => Service['postfix'],
    }
  }

  service { 'saslauthd':
    ensure  => $ensure_service,
    enable  => $enable_service,
    require => Package['libsasl2-modules'],
  }
}
