# the main class of the module

class puppet (
  $master = $puppet::params::master,
  $configtimeout = $puppet::params::configtimeout,
  $server = $puppet::params::server,
  $client_service_flags = $puppet::params::client_service_flags,
  $enable_msgpack_serialization = $puppet::params::enable_msgpack_serialization,
  $preferred_serialization_format = $puppet::params::preferred_serialization_format,
  $config_defaultsfile = $puppet::params::config_defaultsfile,
  $service_name = $puppet::params::service_name,
  $service_ensure = $puppet::params::service_ensure,
  $service_enable = $puppet::params::service_enable,
  $service_provider = $puppet::params::service_provider,
  $package_ensure = $puppet::params::package_ensure,
  $package_name   = $puppet::params::package_name,
  $msgpack_package_name = $puppet::params::msgpack_package_name,
) inherits puppet::params {

  if $master == undef {
    $_master_ensure = 'stopped'
    $_master_enable = false
  } else {
    $_master_esure = 'running'
    $_master_enable = true
  }

  class { 'puppet::install':
    package_name                 => $package_name,
    package_ensure               => $package_ensure,
    msgpack_package_name         => $msgpack_package_name,
    enable_msgpack_serialization => $enable_msgpack_serialization,
  }

  class { 'puppet::config':
    enable_msgpack_serialization   => $enable_msgpack_serialization,
    preferred_serialization_format => $preferred_serialization_format,
    configtimeout                  => $configtimeout,
    server                         => $server,
    config_defaultsfile            => $config_defaultsfile
  }

  if $service_name {
    class { 'puppet::service':
      service_name     => $service_name,
      service_ensure   => $service_ensure,
      service_enable   => $service_enable,
      service_flags    => $client_service_flags,
      service_provider => $service_provider,
    }
    Class['puppet::config'] ~>
    Class['puppet::service']
  }

  Class['puppet::install'] ->
  Class['puppet::config']
}
