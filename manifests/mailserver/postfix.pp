# @summary
#   Ensure the postfix mailserver is configured on the system.
#
class baseline::mailserver::postfix {

  if $baseline::postfix_relayhost == 'direct' {
    notice('Configuring postfix to deliver all mail directly')
    # Mail delivery agent setup
    class { 'postfix':
      mta                 => true,
      mydestination       => $baseline::domain,
      myorigin            => $baseline::domain,
      master_submission   => $baseline::postfix_master_submission,
      relayhost           => $baseline::postfix_relayhost,
      root_mail_recipient => $baseline::owner,
    }
    $myhostname = $baseline::fqdn

    postfix::config { 'relay_domains':
      ensure => present,
      value  => $baseline::postfix_relay_domains,
    }
  } elsif $baseline::postfix_relayhost == 'relay' {
    notice("Configuring postfix to deliver all mail directly, except for ${baseline::domain} which will be relayed to the official MX server")
    # Mail delivery agent setup
    class { 'postfix':
      mta                 => true,
      mydestination       => $baseline::fqdn,
      myorigin            => $baseline::fqdn,
      master_submission   => $baseline::postfix_master_submission,
      relayhost           => 'direct',
      root_mail_recipient => $baseline::owner,
    }
    $myhostname = $baseline::fqdn

    # instruct the exception for relaying $baseline::domain
    file_line { "Instruct postfix to transport all mail for ${baseline::domain} via the default MX ":
      path               => '/etc/postfix/transport',
      line               => "${baseline::domain}\tsmtp",
      match              => "${baseline::domain}",
      append_on_no_match => true,
      notify             => Exec['generate /etc/postfix/transport.db'],
    }
  } elsif $baseline::postfix_relayhost == 'mailhog' {
    $relayhost_local_mailhog = "[${mailhog::smtp_bind_addr_ip}]:${mailhog::smtp_bind_addr_port}"
    notice("Configuring postfix to deliver all mail to mailhog at ${relayhost_local_mailhog}")
    # Mail submission agent with relaying via a smarthost
    class { 'postfix':
      mta                 => false,
      mydestination       => 'blank',
      myorigin            => $baseline::domain,
      master_submission   => $baseline::postfix_master_submission,
      relayhost           => $relayhost_local_mailhog,
      root_mail_recipient => $baseline::owner,
    }
    contain baseline::mailserver::mta

    postfix::hash { '/etc/postfix/transport':
      ensure  => 'present',
      content => "* smtp:localhost:1025\n",
    }
  } else {
    # Mail submission agent with relaying via a smarthost
    class { 'postfix':
      mta                 => true,
      mydestination       => 'blank',
      myorigin            => $baseline::domain,
      master_submission   => $baseline::postfix_master_submission,
      relayhost           => $baseline::postfix_relayhost,
      root_mail_recipient => $baseline::owner,
    }
  }

  postfix::config { 'myhostname':
    ensure => present,
    value  => $baseline::fqdn,
  }

  # Configure Postfix to disable the vrfy command
  postfix::config { 'disable_vrfy_command':
    ensure => present,
    value  => 'yes',
  }

  # Ensure we can receive up to 50MB mail messages
  postfix::config { 'message_size_limit':
    ensure => present,
    value  => '51200000',
  }

}
