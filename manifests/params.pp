class puppet::params {

  case $::osfamily {
    'OpenBSD': {
      if versioncmp( "$::operatingsystemrelease", '5.7' ) > 0 {
        $service_name = 'puppetd'
      } else {
        $service_name = 'puppet'
      }
      $service_provider = undef
    }
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          $service_name = 'puppet'
          $service_provider = undef
        }
        'OpenSuSE': {
          $service_name = 'puppet.service'
          $service_provider = 'systemd'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${operatingsystem}")
        }
      }
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }

  $service_ensure = 'running'
  $service_enable = true
  $master = undef
  $client_service_flags = undef
  $configtimeout = '10m'
  $server = undef
  $package_ensure = 'installed'
  $package_name = 'puppet'
}
