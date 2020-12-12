class baseline::logging {

  class { 'rsyslog':
    preserve_fqdn                  => true,
    local_host_name                => $baseline::fqdn,
    system_log_rate_limit_burst    => 0,
    system_log_rate_limit_interval => 0,
  }

  class { 'rsyslog::client':
    log_remote                => false,
    log_local                 => true,
    high_precision_timestamps => true,
    custom_config             => "baseline/logging.local.conf.erb",
  }
}
