# @summary
#    Validates the setup of signing and verifying (private and public) keys for use with opendkim.
#
# Calls the opendkim-testkey from package opendkim-tools (Debian) and returns the result.
Puppet::Functions.create_function(:'baseline::opendkim_testkey') do
  # @param selector
  #   Names  the  selector  within  the specified domain whose public key should be retrieved and tested,
  #   comparing it to the private key if provided.
  # @param domain
  #   Names  the domain in which signing is to be done.  More specifically, names the domain in which the
  #   public key matching the provided private key will be found.
  #
  dispatch :opendkim_testkey do
    required_param 'String', :selector
    required_param 'Stdlib::Fqdn', :domain
    return_type 'String'
  end

  def opendkim_testkey(selector, domain)
    require 'open3'

    begin
      msg, status = Open3.capture2e(
          '/usr/bin/opendkim-testkey',
          '-vvvv',
          '-s',
          selector,
          '-d',
          domain
      )
      result = status.success? ? '' : msg
    rescue StandardError => e
      result = "Could not get the opendkim status, due to: #{e.inspect}"
    end

    result
  end
end
