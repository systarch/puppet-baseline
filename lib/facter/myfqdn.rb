Facter.add('myfqdn') do
  setcode do
    inventory = Facter.value('inventory')
    networking = Facter.value('networking')
    result =  networking['fqdn']

    # otherwise, we want to guess it based on networking/interfaces facts
    interfaces = Facter.value('networking')['interfaces']
    interfaces.each do |name, interface|
      inventory.each do |hostname, inventory_item|
        match = inventory_item[:indicator].select{|k,v| interface.key?(k) and interface[k] == v }
        next if match.empty?
        result = hostname
        Facter.debug "Identified #{hostname} from #{match}"
      end
    end
    result
  end
end
