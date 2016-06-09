# private class, do not use directly
# steers the parameters that drive the class
class puppet::params {

  case $::osfamily {
    'Debian': {
      $puppet_user = 'puppet'
      $puppet_group = 'puppet'
      $master_service_name = 'puppetmaster'
      $service_name = 'puppet'
      $master_package = 'puppetmaster'
      $service_provider = undef
      $msgpack_package_name = undef
      $config_defaultsfile = '/etc/default/puppet'
      $package_name = 'puppet'
    }
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
      $puppet_user = '_puppet'
      $puppet_group = '_puppet'
      $service_provider = undef
      $master_package = undef
      $msgpack_package_name = "ruby${rubyversion}-msgpack"
      $config_defaultsfile = undef
      $rubyunicorn = "/usr/local/bin/unicorn${rubyversion}"
      $unicorn_conf = "${::settings::confdir}/unicorn.conf"
      $unicorn_flags = "-D -c ${unicorn_conf}"
      $unicorn_workers = '8'
      # nginx runs chrooted, as well as other webservers
      $unicorn_socket = '/var/www/run/puppet/puppetmaster_unicorn.sock'
      $unicorn_timeout = '120'
      $unicorn_socket_chrooted = '/run/puppet/puppetmaster_unicorn.sock'
      $unicorn_pid = "${::settings::rundir}/puppetmaster_unicorn.pid"
      $unicorn_package = "ruby${rubyversion}-unicorn"
      $package_name = 'puppet'
    }
    'Suse': {
      case $::operatingsystem {
        'SLES': {
          $service_name = 'puppet'
          $master_service_name = 'puppetmaster'
          $config_defaultsfile = '/etc/sysconfig/puppet'
          case $::operatingsystemrelease {
            '12.0': {
              $service_provider = 'systemd'
              $package_name = 'rubygem-puppet'
            }
            default: {
              $service_provider = 'init'
              $package_name = 'puppet'
            }
          }
        }
        'OpenSuSE': {
          $service_name = 'puppet.service'
          $service_provider = 'systemd'
          $master_service_name = 'puppetmaster'
          $config_defaultsfile = undef
          $package_name = 'puppet'
        }
        default: {
          fail("${::module_name}: unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
      $master_package = undef
      $puppet_user = 'puppet'
      $puppet_group = 'puppet'
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
  $parser = undef                   # maybe 'future'
  $runinterval = '1800'
  $stringify_facts = true       # store facts as strings in PuppetDB, set to false to
                                # store them as hashes, or arrays
  $configtimeout = '10m'
  $puppet_env = undef           # use the default 'production' environment
  $autosign = undef             # manage CA autosigning, true, false or path to autosign.conf file
  $server = undef               # use the default 'puppet'
  $package_ensure = 'installed'

  # Whether this module manages the webservers vhost
  $manage_vhost = true

  $dbhost = 'localhost'
  $dbuser = 'puppetdb'
  $dbpass = 'puppetdb'
  $dbname = 'puppetdb'
  $dbtable = 'autosign_requests'
}
