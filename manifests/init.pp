# @summary
#   Main entry point for a systemconfig installation
#
class baseline (
  String $owner, # <--- That's you or whoever wants to receive all the automated mail ;-)
  String $organization_name, # <--- That's your company or the organization name of the client
  Stdlib::Fqdn $fqdn        = $baseline::params::fqdn,
  Stdlib::Fqdn $domain      = $baseline::params::domain,
  String $zone              = $baseline::params::zone,
  String $scriptprefix      = 'systemconfig',

  # mail settings
  $postfix_relayhost        = $baseline::params::postfix_relayhost,
  $postfix_relay_domains    = '',
  Array[Stdlib::Fqdn] $opendkim_domains  = $baseline::params::opendkim_domains,
  String $opendkim_selector = $baseline::params::opendkim_selector,
  $postfix_virtual          = {},
  Boolean $enable_sasl_auth = false,
  $certificates             = {},

  # primary domain / default vhost webserver settings
  $webserver_docroot        = $baseline::params::webserver_docroot,
  $webserver_wellknown_dir  = $baseline::params::webserver_wellknown_dir,

  # extra everythings
  $extra_directories        = {},
  $extra_packages           = $baseline::params::extra_packages,
  $extra_packages_backports = {},
) inherits baseline::params {
  if !$fqdn {
    fail('FQDN is unknown for this machine. Add to the inventory.yaml first!')
  }

  # declare the path to these files for other modules to depend and refresh services
  $tls_cert_file      = "/etc/letsencrypt/live/${fqdn}/cert.pem"
  $tls_key_file       = "/etc/letsencrypt/live/${fqdn}/privkey.pem"
  $tls_chain_file     = "/etc/letsencrypt/live/${fqdn}/chain.pem"
  $tls_fullchain_file = "/etc/letsencrypt/live/${fqdn}/fullchain.pem"

  # controlled via baseline::enable_sasl_auth: yes/no
  $postfix_master_submission = $baseline::params::postfix_master_submission

  notice("--< ${fqdn}: ${scriptprefix}/${module_name}  >--------------------------------------------")
  ensure_resources('file', $extra_directories)
  ensure_resources('package', $extra_packages)

  contain accounts
  contain locales
  contain fail2ban
  contain letsencrypt

  $distro_classname = sprintf('baseline::distro::%s', $::os['distro']['id'].downcase)
  include $distro_classname
  contain baseline::puppet
  contain baseline::ssh
  contain baseline::hostname
  contain baseline::bashrc
  contain baseline::mailserver
  contain baseline::unattended_upgrades
  contain baseline::hardening
  contain baseline::pki
  contain baseline::logging

  # install all defined vhosts via their $vhost_type definition
  ensure_resources('postfix::virtual', $postfix_virtual)

  Class['letsencrypt'] -> Baseline::Certificate <| |> -> Class['baseline::mailserver']
}
