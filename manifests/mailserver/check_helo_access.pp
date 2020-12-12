# @summary
#   Allow exceptions when receiving mail for misconfigured servers
#
class baseline::mailserver::check_helo_access {

  postfix::hash { '/etc/postfix/helo_access':
    ensure  => 'present',
    content => lookup({
      name => 'baseline::mailserver::check_helo_access::content',
      default_value => "\n",
    }),
  }
}
