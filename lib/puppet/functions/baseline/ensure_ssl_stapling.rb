# @summary
#    Returns either 'present' or 'absent', depending on whether the current certificate
#    for ${fqdn} is present and has stapling activated
#
Puppet::Functions.create_function(:'baseline::ensure_ssl_stapling') do
  # @param commonname
  #   Common name of the certificate that should be checked.
  #
  dispatch :ensure_ssl_stapling do
    required_param 'Stdlib::Fqdn', :fqdn
    return_type "Struct[{ensure_ssl => Enum['present', 'absent'], privkey => Stdlib::Unixpath, fullchain => Stdlib::Unixpath}]"
  end

  def get_server_certificate(fqdn)
    fullchain = "/etc/ssl/#{fqdn}/server.fullchain.pem"
    fullchain = "/etc/letsencrypt/live/#{fqdn}/fullchain.pem" unless File.exist?(fullchain)

    # check the certificate whether it contains must staple attribute

    return result
  end
end
