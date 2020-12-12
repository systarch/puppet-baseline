# @summary
#   Ensure the postfix mail server is hardened against spam senders
#
class baseline::mailserver::spam_hardening {

  # Reject Email if SMTP Client Has no PTR record
  postfix::config { 'smtpd_sender_restrictions':
    ensure => present,
    value  => [
      'permit_sasl_authenticated',
      'permit_mynetworks',
      'reject_unknown_sender_domain',
      'reject_unknown_reverse_client_hostname',
      'reject_unknown_client_hostname',
    ].join(' '),
  }

  # Enable HELO/EHLO Hostname Restrictions in Postfix
  postfix::config { 'smtpd_helo_required':
    ensure => present,
    value  => 'yes',
  }
  postfix::config { 'smtpd_helo_restrictions':
    ensure => present,
    value  => [
      'permit_mynetworks',
      'check_helo_access hash:/etc/postfix/helo_access',
      'reject_invalid_helo_hostname',
      'reject_non_fqdn_helo_hostname',
      'reject_unknown_helo_hostname',
    ].join(' '),
  }

}