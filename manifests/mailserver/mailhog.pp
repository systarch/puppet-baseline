# @summary
#   Ensure mailhog is configured according to the systemconfig zone's requirements
#
class baseline::mailserver::mailhog {

  class { 'mailhog':
    ensure              => ($baseline::postfix_relayhost) ? {
      'mailhog' => present,
      default   => absent,
    },
    smtp_bind_addr_port => 1025,
  }

}