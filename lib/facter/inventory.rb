require 'facter'
require 'open3'
require 'yaml'

module Systemconfig
  module Facts
    # Method to call the Facter DSL and dynamically add facts at runtime.
    #
    # This method is necessary to add reasonable RSpec coverage for the custom
    # fact
    #
    # @return [NilClass]
    def self.add_facts
      Facter.add(:inventory) do
        confine :kernel => "Linux"
        setcode do
          Systemconfig::Facts::Inventory.new.to_facts
        end
      end

      return nil
      end

    class Inventory

      INVENTORY_FILENAME_PATTERN = '/usr/share/systemconfig/hiera/**/*.yaml'
      attr_accessor :facts

      def initialize(filename_pattern = INVENTORY_FILENAME_PATTERN)
        self.facts = inventory(filename_pattern)
      end

      def to_facts
        hash = {}
        self.facts.each { |k,v| hash[k] = v }
        hash
      end

      private

      def inventory(filename_pattern)
        result = {}

        # scan all files in ../hiera
        nodes = Dir.glob(filename_pattern).select{ |e| File.file? e }

        nodes.each { |filename|
          hostname = File.basename filename, '.yaml'
          next if %w(common global).include?(hostname) or hostname.start_with?('common:')
          hiera_data = YAML::load(File.open(filename, 'r'))
          unless hiera_data.is_a?(Hash)
            Facter.warn("WARNING: Can't identify #{hostname} as there is no valid YAML data in #{filename}")
            next
          end
          unless hiera_data.key?('inventory::indicator')
            puts hiera_data.keys.to_yaml
            Facter.warn("WARNING: #{hostname} can't be identified as it does not contain a 'inventory::indicator:: {ip: x.x.x.x}' in #{filename}.")
            next
          end

          # fetch the primary domain part: if there is a :{zone} suffix, interpret it
          myzone = 'prod'
          mydomain = File.basename File.dirname filename
          if mydomain.include?(':')
            parts = mydomain.split(':')
            mydomain = parts[0]
            myzone = parts[1]
            hostname = "#{hostname}.#{myzone}.#{mydomain}" unless hostname.include?('.')
          else
            hostname = "#{hostname}.#{mydomain}" unless hostname.include?('.')
          end
          myzone = hiera_data.key?('baseline::zone') ? hiera_data['baseline::zone'] : myzone

          result[hostname] = {
              indicator: hiera_data['inventory::indicator'],
              zone: myzone,
              domain: mydomain,
              realm: "#{myzone}.#{mydomain}",
          }
        }
        result
      end
    end
  end
end

# If we're being loaded inside the module, we'll need to go ahead and add our
# facts then won't we?

Systemconfig::Facts.add_facts
