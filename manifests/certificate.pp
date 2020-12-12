# @summary Request a certificate using the `selfsigned` installer
#
# @param ensure
#   Intended state of the resource
#   Will remove certificates for specified domains if set to 'absent'. Will
#   also remove cronjobs and renewal scripts if `manage_cron` is set to 'true'.
# @param domains
#   An array of domains to include in the CSR.
#
define baseline::certificate(
  Enum['present','absent'] $ensure = present,
  Array[String[1]] $domains = [],
){
  $parts = $name.match(/^(selfsigned::client_certificate|selfsigned::server_certificate|letsencrypt):(.*)$/)
  if count($parts)==3 {
    $provider = $parts[1]
    $servername = $parts[2]
    notice("matched provider='${provider}' for fqdn=${servername}")
  } else {
    fail('Expected certificate resource definition in the form [certificate_type]:[commonname]')
  }

  if $provider == 'letsencrypt' {
    letsencrypt::certonly { $servername:
      ensure        => $ensure,
      domains       => unique([$servername] + $domains),
      plugin        => 'webroot',
      webroot_paths => [$baseline::webserver_docroot],
    }
  } elsif $provider.match(/^selfsigned::(client|server)_certificate/) {
    ensure_resource($provider, $servername, {
      ensure => $ensure,
    })
  } else {
    fail("Should create a '${provider}' certificate for ${servername}, but no certificate provider was provided...")
  }

}