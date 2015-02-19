
class puppet (
  $master = $puppet::params::master,
  $configtimeout = $puppet::params::configtimeout,
  $server = $puppet::params::server,
  $client_service_flags = $puppet::params::client_service_flags,
  $service_name = $puppet::params::service_name,
  $service_ensure = $puppet::params::service_ensure,
  $service_enable = $puppet::params::service_enable,
  $package_ensure = $puppet::params::package_ensure,
  $package_name   = $puppet::params::package_name,
) inherits puppet::params { 

  if $master == undef {
    $_master_ensure = "stopped"
    $_master_enable = "false"
  } else {
    $_master_esure = "running"
    $_master_enable = "true"
  }

  class { 'puppet::install':
    package_name   => $package_name,
    package_ensure => $package_ensure,
  }

  class { 'puppet::config':
    configtimeout => $configtimeout,
    server        => $server,
  }

  if $service_name {
    class { 'puppet::service':
      service_name   => $service_name,
      service_ensure => $service_ensure,
      service_enable => $service_enable,
      service_flags  => $client_service_flags,
    }
    Class['puppet::config'] ->
    Class['puppet::service']
  }

  Class['puppet::install'] ->
  Class['puppet::config']
}
