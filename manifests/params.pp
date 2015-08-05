# private class, do not use directly
# steers the parameters that drive the class
class puppet::params {

  $config_dir = '/etc/puppet'
  $run_dir = '/var/puppet/run'

  case $::osfamily {
    'OpenBSD': {
      if (versioncmp( $::kernelversion, '5.8' ) < 0) {
        $service_name = 'puppetd'
	$master_service_name = 'puppetmasterd'
        $rubyversion = '21'
      } else {
        $service_name = 'puppet'
	$master_service_name = 'puppetmaster'
        $rubyversion = '22'
      }
      $service_provider = undef
      $msgpack_package_name = "ruby${rubyversion}-msgpack"
      $config_defaultsfile = undef
      $rubyunicorn = "/usr/local/bin/unicorn${rubyversion}"
      $unicornflags = "-D -c ${config_dir}/unicorn.conf"
      $unicorn_workers = '8'
      $unicorn_socket = "${run_dir}/puppetmaster_unicorn.sock"
      $unicorn_pid = "${run_dir}/puppetmaster_unicorn.pid"
      $unicorn_package = "ruby${rubyversion}-unicorn"
    }
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          $service_name = 'puppet'
          $service_provider = undef
          $config_defaultsfile = '/etc/sysconfig/puppet'
        }
        'OpenSuSE': {
          $service_name = 'puppet.service'
          $service_provider = 'systemd'
          $config_defaultsfile = undef
        }
        default: {
          fail("${::modulename}: unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
      $msgpack_package_name = undef
    }
    default: {
      fail("${::modulename}: unsupported platform: ${::osfamily}")
    }
  }

  $service_ensure = 'running'
  $service_enable = true
  $master = undef	# can be: standalone, unicorn, passenger
  $client_service_flags = undef
  $enable_msgpack_serialization = undef
  $preferred_serialization_format = msgpack
  $configtimeout = '10m'
  $server = undef
  $package_ensure = 'installed'
  $package_name = 'puppet'
}
