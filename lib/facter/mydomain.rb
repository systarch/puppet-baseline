Facter.add('mydomain') do
  setcode do
    inventory = Facter.value('inventory')
    myfqdn = Facter.value('myfqdn')
    inventory.key?(myfqdn) ? inventory[myfqdn][:domain] : myfqdn
  end
end