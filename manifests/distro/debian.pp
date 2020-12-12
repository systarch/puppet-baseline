# @summary
#   Manage Debian specific dependencies and installation requirements

class baseline::distro::debian {

  if $baseline::extra_packages_backports.length > 0 {
    class { 'apt::backports':
      location => 'http://ftp.de.debian.org/debian',
      release  => 'buster-backports',
      repos    => 'main',
      pin      => 200,
    }

    # pin the extra backports package
    $baseline::extra_packages_backports.keys.each |$package_name| {
      apt::pin { "backports_${package_name}":
        packages => $package_name,
        priority => 500,
        release  => 'main',
      }
    }
  }

  Class['apt::update'] -> Package <| provider == 'apt' |>

  # ensure the backports packages to whatever
  ensure_resources('package', $baseline::extra_packages_backports)
}
