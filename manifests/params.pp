# private class, do not use directly
# steers the parameters that drive the class
class puppet::params {

  case $::osfamily {
    'OpenBSD': {
      if versioncmp( $::operatingsystemrelease, '5.7' ) > 0 {
        $service_name = 'puppet'
      } else {
        $service_name = 'puppetd'
      }
      $service_provider = undef
      $msgpack_package_name = 'ruby21-msgpack'
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
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
      $msgpack_package_name = undef
    }
    default: {
      fail("Unsupported platform: ${::osfamily}")
    }
  }

  $service_ensure = 'running'
  $service_enable = true
  $master = undef
  $client_service_flags = undef
  $enable_msgpack_serialization = undef
  $preferred_serialization_format = msgpack
  $configtimeout = '10m'
  $server = undef
  $package_ensure = 'installed'
  $package_name = 'puppet'
}
