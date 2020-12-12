# @summary
#   Manage the startup script that sets the system's hostname to the desired FQDN
#
class baseline::hostname {

  $hostname = $baseline::fqdn
  file { '/etc/init.d/hostname_vps':
    owner   => 'root',
    group   => 'staff',
    mode    => '0500',
    content => template('baseline/hostname.init-script.bash.erb'),
  }

  # create runlevel symlinks
  file { '/etc/rc0.d/K01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc1.d/K01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc2.d/S01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc3.d/S01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc4.d/S01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc5.d/S01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }
  file { '/etc/rc6.d/K01hostname_vps': ensure => 'link', target => '../init.d/hostname_vps', require => File['/etc/init.d/hostname_vps'], }

  if $::networking['fqdn'] != $baseline::fqdn {
    err("System FQDN is currently set to ${::networking['fqdn']}:\nPlease reboot when ready!")
    exec { 'initialize the hostname_vps service':
      command => '/usr/sbin/update-rc.d hostname_vps defaults 09',
      require => [
        File['/etc/init.d/hostname_vps'],
        File['/etc/rc0.d/K01hostname_vps'],
        File['/etc/rc1.d/K01hostname_vps'],
        File['/etc/rc2.d/S01hostname_vps'],
        File['/etc/rc3.d/S01hostname_vps'],
        File['/etc/rc4.d/S01hostname_vps'],
        File['/etc/rc5.d/S01hostname_vps'],
        File['/etc/rc6.d/K01hostname_vps'],
      ],
    }
  }
}