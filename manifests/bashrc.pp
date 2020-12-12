# @summary
#   Configure the systemconfig wide bashrc environment settings
class baseline::bashrc {

  file_line { 'Set global bashrc to always show the full hostname':
    path               => '/etc/bash.bashrc',
    append_on_no_match => true,
    match              => '^PS1=',
    line               => 'PS1=\'${debian_chroot:+($debian_chroot)}\u@\H:\w\$ \'',
  }

  file_line { 'Set user bashrc to always include the personal bin':
    path  => '/etc/profile',
    match => '^  PATH="/usr/local/bin:',
    line  => '  PATH="/usr/local/bin:/usr/bin:/bin:${HOME}/bin"',
  }

  file { '/etc/bashrc.puppet':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('baseline/bashrc.puppet.erb'),
  }

  # if we're on buster, add the /opt/puppetlabs/bin to PATH
  if $::os['release']['major'] == '9' {
    file_line { 'Add /opt/puppetlabs/bin to the global path (only buster)':
      path  => '/etc/profile',
      match => '^  PATH="/usr/local/sbin:',
      line  => '  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin"',
    }
  }

}