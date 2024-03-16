# private class, do not use directly
# steers the parameters that drive the class
class puppet::params {

  case $facts['os']['family'] {
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
      if (versioncmp( $facts['kernelversion'], '5.7' ) < 0) {
        $service_name = 'puppetd'
        $master_service_name = 'puppetmasterd'
      } else {
        $service_name = 'puppet'
        $master_service_name = 'puppetmaster'
      }
      $rubyversion = regsubst($facts['ruby']['version'], '^(\d+)\.(\d+)\.(\d+)$', '\1\2')
      $puppet_user = '_puppet'
      $puppet_group = '_puppet'
      $service_provider = undef
      $master_package = undef
      $msgpack_package_name = "ruby${rubyversion}-msgpack"
      $config_defaultsfile = undef
      $rubyunicorn = "/usr/local/bin/unicorn${rubyversion}"
      $unicorn_conf = "${::puppet_confdir}/unicorn.conf"
      $unicorn_flags = "-D -c ${unicorn_conf}"
      $unicorn_workers = '8'
      # nginx runs chrooted, as well as other webservers
      $unicorn_socket = '/var/www/run/puppet/puppetmaster_unicorn.sock'
      $unicorn_timeout = '120'
      $unicorn_socket_chrooted = '/run/puppet/puppetmaster_unicorn.sock'
      $unicorn_pid = "${::puppet_rundir}/puppetmaster_unicorn.pid"
      $unicorn_package = "ruby${rubyversion}-unicorn"
      $package_name = 'puppet'
    }
    'Suse': {
      case $facts['os']['name'] {
        'SLES': {
          $service_name = 'puppet'
          $master_service_name = 'puppetmaster'
          $config_defaultsfile = '/etc/sysconfig/puppet'
          case $facts['os']['release']['full']{
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
          fail("${module_name}: unsupported platform: ${facts['os']['family']}/${facts['os']['name']}")
        }
      }
      $master_package = undef
      $puppet_user = 'puppet'
      $puppet_group = 'puppet'
      $msgpack_package_name = undef
    }
    default: {
      fail("${module_name}: unsupported platform: ${facts['os']['family']}")
    }
  }

  # Default daemon on OpenBSD logs to daemon as well as messages :(
  $syslogfacility = 'user'
  $service_ensure = 'running'
  $service_enable = true
  $master = false  # can be: webrick, unicorn, passenger
  $master_service_flags = undef
  $webserver_frontend = undef       # can be: nginx, apache2
  $client_service_flags = undef
  $enable_msgpack_serialization = undef
  $disable_warnings = undef
  $preferred_serialization_format = msgpack
  $parser = undef                   # maybe 'future'
  $runinterval = '1800'
  $stringify_facts = true       # store facts as strings in PuppetDB, set to false to
                                # store them as hashes, or arrays
  if (versioncmp($facts['puppetversion'], '4') < 0) {
    $configtimeout = '10m'
  } else {
    $configtimeout = undef
  }
  $include_legacy_facts = true  # true as long as https://github.com/voxpupuli/puppetboard/issues/960
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
