# @summary
#   Ensures the server is configured to apply unattended security updates automatically.
#
# @api private
class baseline::unattended_upgrades(
  $maintenance_packages = [
    'unattended-upgrades',
    'apt-listchanges',
  ],
) {

  ensure_resource('package', $maintenance_packages, { ensure => latest })

  file { '/etc/apt/apt.conf.d/20auto-upgrades':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0444',
    source => 'puppet:///modules/baseline/maintenance.apt.conf.d.20auto-upgrades.conf',
  }

  file { '/etc/apt/apt.conf.d/50unatended-upgrades':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0444',
    source => 'puppet:///modules/baseline/maintenance.apt.conf.d.50unattended-upgrades.conf',
  }

}
