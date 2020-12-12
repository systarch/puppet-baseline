# @summary
#   This class manages systemconfig's baseline default settings
#
# @api private
class baseline::params {
  $fqdn = $facts['myfqdn']
  $domain = $facts['mydomain']
  $zone = $facts['myzone']
  unless has_key($facts['inventory'], $fqdn) {
    warning("WARNING:")
    warning("This machine does not yet have an 'inventory::indicator' setting in hiera.")
    warning("Only global settings will be applied.")
    warning("Settings that will be used:")
    warning("myfqdn: '${fqdn}'")
    warning("mydomain: '${domain}'")
    warning("myzone: '${zone}'")
  }

  $postfix_relayhost = lookup({
    'name'          => 'baseline::postfix_relayhost',
    'default_value' => 'mailhog',
  })

  if $postfix_relayhost == 'mailhog' {
    $mailserver = 'baseline::mailhog'
  } else {
    $mailserver = 'baseline::mailserver'
  }
  notice("baseline::mailserver will relay mail: ${postfix_relayhost}")
  if ($postfix_relayhost == 'mailhog' and $zone == 'prod') {
    fail('Refusing to install mailhog in production...')
  }

  $_fqdn_parts = split($fqdn, '[.]')
  $opendkim_selector = $_fqdn_parts[0]

  $opendkim_domains = [$domain]

  $baseline_enable_sasl_auth = lookup({
    'name'          => 'baseline::enable_sasl_auth',
    'default_value' => 'no',
  })

  if str2bool($baseline_enable_sasl_auth) {
    $postfix_master_submission = template('baseline/postfix.master.cf_submission.erb')
  } else {
    $postfix_master_submission = "\n# Activate submission port + Cyrus SASL via hiera: baseline::enable_sasl_auth: 'yes'\n\n"
  }

  # Not all machines have a webserver running --> find better place...
  $webserver_docroot = lookup({
    'name'          => 'webserver::docroot',
    'default_value' => '/var/www/html',
  })
  $webserver_wellknown_dir = "${webserver_docroot}/.well-known"

  $extra_packages = {
    'cron' => {ensure => latest},
    'curl' => {ensure => latest},
  }
}