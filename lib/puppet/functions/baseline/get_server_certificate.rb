# @summary
#    Returns either 'present' or 'absent' for the defined certificate and presence of key material
#
Puppet::Functions.create_function(:'baseline::get_server_certificate') do
  # @param commonname
  #   Common name of the certificate that should be checked.
  #
  dispatch :get_server_certificate do
    required_param 'Stdlib::Fqdn', :fqdn
    return_type "Struct[{ensure_ssl => Enum['present', 'absent'], privkey => Stdlib::Unixpath, fullchain => Stdlib::Unixpath}]"
  end

  def get_server_certificate(fqdn)
    result = {
        'ensure_ssl' => 'absent',
        'privkey'    => '/dev/null',
        'fullchain'  => '/dev/null',
    }

    selfsigned = {
        'ensure_ssl' => 'present',
        'privkey'    => "/etc/ssl/#{fqdn}/server.privkey.pem",
        'fullchain'  => "/etc/ssl/#{fqdn}/server.fullchain.pem",
    }
    result = selfsigned if File.exist?(selfsigned['privkey']) and File.exist?(selfsigned['fullchain'])

    letsencrypt = {
        'ensure_ssl' => 'present',
        'privkey'    => "/etc/letsencrypt/live/#{fqdn}/privkey.pem",
        'fullchain'  => "/etc/letsencrypt/live/#{fqdn}/fullchain.pem"
    }
    result = letsencrypt if File.exist?(letsencrypt['privkey']) and File.exist?(letsencrypt['fullchain'])

    return result
  end
end
