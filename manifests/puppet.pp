# @summary
#   Ensure the puppet agent service is disabled and stopped.
#
# @api private
class baseline::puppet {

  # Deactivate the puppet service as we're running masterless
  service {'puppet':
    ensure => stopped,
    enable => false,
  }
}