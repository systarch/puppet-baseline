# @summary
#   Manage systemconfig-specific hardening recipes
#
class baseline::hardening {
  require accounts::user::defaults

  # ensure dev servers get rid of the NFS server and rpcbind
  package { ['nfs-kernel-server', 'rpcbind']:
    ensure => absent,
  }

  # ensure apache run user www-data and the application owner can share directories
  file_line { 'Ensure apache run-user www-data and application owners can share directories':
    path  => '/etc/login.defs',
    line  => 'UMASK 002',
    match => '^UMASK.*',
  }

  # activate umask pam module
  file_line { 'Activate umask pam module for common sessions':
    path  => '/etc/pam.d/common-session',
    line  => "session optional\tpam_umask.so",
    match => 'pam_umask.so$',
  }
  file_line { 'Activate umask pam module for cron and sudo sessions':
    path  => '/etc/pam.d/common-session-noninteractive',
    line  => "session optional\tpam_umask.so",
    match => 'pam_umask.so$',
  }


  # for all new user accounts, create a /etc/skel entry
  file { ['/etc/skel/.puppetlabs', '/etc/skel/.puppetlabs/bolt']:
    ensure => directory,
  }

  file { '/etc/skel/.puppetlabs/bolt/analytics.yaml':
    ensure  => file,
    content => "---\ndisabled: true\n",
    require => File['/etc/skel/.puppetlabs/bolt'],
  }

  $managed_accounts = $accounts::user_list.filter |$name, $account| {
    (!has_key($account, 'managedhome') or $account['managedhome']) and (!has_key($account, 'ensure') or $account['ensure']!='absent')
  }

  $managed_accounts.each |$name, $account| {
    $user_home_dir = has_key($account, 'home') ? {
      true    => $account['home'],
      default => $name ? {
        'root'  => $accounts::user::defaults::root_home,
        default => $accounts::user::defaults::home_template.sprintf($name),
      },
    }

    file { ["${user_home_dir}/.puppetlabs", "${user_home_dir}/.puppetlabs/bolt"]:
      ensure  => directory,
      owner   => $name,
      require => User[$name],
    }

    -> file { "${user_home_dir}/.puppetlabs/bolt/analytics.yaml":
      ensure  => file,
      owner   => $name,
      content => "---\ndisabled: true\n",
    }
  }
}
