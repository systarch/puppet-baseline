# @summary
#    Gets the reverse DNS lookup result for a given IPv4 or IPv6 address.
#
Puppet::Functions.create_function(:'baseline::reverse_dns_lookup') do
  # @param selector
  #   Names  the  selector  within  the specified domain whose public key should be retrieved and tested,
  #   comparing it to the private key if provided.
  # @param domain
  #   Names  the domain in which signing is to be done.  More specifically, names the domain in which the
  #   public key matching the provided private key will be found.
  #
  dispatch :reverse_dns_lookup do
    required_param 'Stdlib::Ip', :ip
    return_type 'Stdlib::Fqdn'
  end

  def reverse_dns_lookup(ip)
    require 'open3'

    begin
      msg, status = Open3.capture2e(
          '/usr/bin/dig',
          '-x',
          ip
      )
      result = status.success? ? '' : msg
    rescue StandardError => e
      result = "Could not get the reverse DNS status, due to: #{e.inspect}"
    end
    result
  end
end
