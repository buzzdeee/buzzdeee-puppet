
class puppet (
  $master = $puppet::params::master,
  $configtimeout = $puppet::params::configtimeout,
  $server = $puppet::params::server,
  $client_service_flags = $puppet::params::client_service_flags,
  $service_name = $puppet::params::service_name,
  $service_ensure = $puppet::params::service_ensure,
  $service_enable = $puppet::params::service_enable,
) inherits puppet::params { 

  package { 'puppet': ensure => "present" }

  if $master == undef {
    $_master_ensure = "stopped"
    $_master_enable = "false"
  } else {
    $_master_esure = "running"
    $_master_enable = "true"
  }

  class { puppet::config:
    configtimeout => $configtimeout,
    server        => $server,
  }

  if $service_name {
    service { $service_name:
      require => Package['puppet'],
      ensure  => $service_ensure,
      enable  => $service_enable,
      flags   => $client_service_flags,
    }
  }
  #service { "puppetmasterd":
  #  require 	=> Package['puppet'],
  #  ensure  	=> $_master_ensure,
  #  enable  	=> $_master_enable,
  #}
}
