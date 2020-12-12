# @summary
#   Guides the basic setup and installation of the postfix mailserver on your system.
#
class baseline::mailserver {
  contain baseline::mailserver::mailhog
  contain baseline::mailserver::postfix

  if $baseline::postfix_relayhost in ['direct', 'relay']  {
    contain baseline::mailserver::opendkim
    contain baseline::mailserver::sasl_authentication
    contain baseline::mailserver::check_helo_access
    contain baseline::mailserver::spam_hardening
    contain baseline::mailserver::tls
    contain baseline::mailserver::tls_hardening
  }

  Class['mailhog'] -> Class['baseline::mailserver::postfix']

}
