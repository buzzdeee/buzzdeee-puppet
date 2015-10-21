# private class, do not use directly
# steers the parameters that drive the class
class puppet::params {

  $config_dir = '/etc/puppet'
  $run_dir = '/var/puppet/run'

  case $::osfamily {
    'OpenBSD': {
      if (versioncmp( $::kernelversion, '5.7' ) < 0) {
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
      $unicorn_conf = "${config_dir}/unicorn.conf"
      $unicorn_flags = "-D -c ${unicorn_conf}"
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
          $master_service_name = 'puppetmaster'
          $config_defaultsfile = '/etc/sysconfig/puppet'
        }
        'OpenSuSE': {
          $service_name = 'puppet.service'
          $service_provider = 'systemd'
          $master_service_name = 'puppetmaster'
          $config_defaultsfile = undef
        }
        default: {
          fail("${::module_name}: unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
      $msgpack_package_name = undef
    }
    default: {
      fail("${::module_name}: unsupported platform: ${::osfamily}")
    }
  }

  $service_ensure = 'running'
  $service_enable = true
  $master = false  # can be: webrick, unicorn, passenger
  $webserver_frontend = undef       # can be: nginx, apache2
  $client_service_flags = undef
  $enable_msgpack_serialization = undef
  $preferred_serialization_format = msgpack
  $runinterval = '1800'
  $configtimeout = '10m'
  $puppet_env = undef           # use the default 'production' environment
  $autosign = undef             # manage CA autosigning, true, false or path to autosign.conf file
  $server = undef               # use the default 'puppet'
  $package_ensure = 'installed'
  $package_name = 'puppet'
}
