class puppet::params {

  case $::osfamily {
    'OpenBSD': {
      $service_name = 'puppetd'
    }
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          $service_name = 'puppet'
        }
        'OpenSuSE': {
          $service_name = undef
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
