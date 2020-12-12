# @summary
#   Ensure SSH is configured to allow access only with authorized keys
#
# @api private
class baseline::ssh {

  class { 'ssh':
    storeconfigs_enabled => false,
    server_options       => {
      'PasswordAuthentication' => 'no',
      'PermitEmptyPasswords'   => 'no',
      'PermitRootLogin'        => 'prohibit-password',
      'SyslogFacility'         => 'AUTHPRIV',
      'UsePAM'                 => 'yes',
      'X11Forwarding'          => 'no',
    },
  }
}
