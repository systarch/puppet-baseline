Facter.add('myzone') do
  setcode do
    inventory = Facter.value('inventory')
    myfqdn = Facter.value('myfqdn')
    inventory.key?(myfqdn) ? inventory[myfqdn][:myrealm] : ''
  end
end