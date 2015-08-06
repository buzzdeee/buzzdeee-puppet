# the main class of the module

class puppet (
  $config_dir = $puppet::params::config_dir,
  $run_dir = $puppet::params::run_dir,
  $master = $puppet::params::master,
  $configtimeout = $puppet::params::configtimeout,
  $server = $puppet::params::server,
  $client_service_flags = $puppet::params::client_service_flags,
  $enable_msgpack_serialization = $puppet::params::enable_msgpack_serialization,
  $preferred_serialization_format = $puppet::params::preferred_serialization_format,
  $config_defaultsfile = $puppet::params::config_defaultsfile,
  $service_name = $puppet::params::service_name,
  $master_service_name = $puppet::params::master_service_name,
  $master_service_flags = $puppet::params::master_service_flags,
  $service_ensure = $puppet::params::service_ensure,
  $service_enable = $puppet::params::service_enable,
  $service_provider = $puppet::params::service_provider,
  $package_ensure = $puppet::params::package_ensure,
  $package_name   = $puppet::params::package_name,
  $msgpack_package_name = $puppet::params::msgpack_package_name,
  $rubyversion = $puppet::params::rubyversion,
  $unicorn_flags = $puppet::params::unicornflags,
  $unicorn_workers = $puppet::params::unicorn_workers,
  $webserver_frontend = $puppet::params::webserverfrontend,
) inherits puppet::params {

  if $master {
    if $::operatingsystem != 'OpenBSD' {
      fail("${::modulename}: managing a Puppet master is not supported on ${::operatingsystem}")
    }
    case $master {
      'webrick': {
        class { '::puppet::master::webrick':
          ensure               => 'running',
          enable               => true,
          master_service_name  => $master_service_name,
          master_service_flags => $master_service_flags,
        }
        class { '::puppet::master::unicorn':
          ensure             => 'stopped',
          enable             => false,
          rubyversion        => $rubyversion,
          rubyunicorn        => $puppet::params::rubyunicorn,
          unicorn_workers    => $unicorn_workers,
          unicorn_package    => $puppet::params::unicorn_package,
          config_dir         => $config_dir,
          unicorn_conf       => $puppet::params::unicorn_conf,
          unicorn_socket     => $puppet::params::unicorn_socket,
          unicorn_pid        => $puppet::params::unicorn_pid,
          unicorn_flags      => $unicorn_flags,
          webserver_frontend => $webserver_frontend,
          before             => Class['puppet::master::webrick'],
        }
        class { '::puppet::master::passenger':
          ensure => 'stopped',
          enable => false,
          before => Class['puppet::master::unicorn'],
        }
      }
      'unicorn': {
        class { '::puppet::master::webrick':
          ensure               => 'stopped',
          enable               => false,
          master_service_name  => $master_service_name,
          master_service_flags => $master_service_flags,
          before               => Class['puppet::master::unicorn'],
        }
        class { '::puppet::master::unicorn':
          ensure             => 'running',
          enable             => true,
          rubyversion        => $rubyversion,
          rubyunicorn        => $puppet::params::rubyunicorn,
          unicorn_workers    => $unicorn_workers,
          unicorn_package    => $puppet::params::unicorn_package,
          config_dir         => $config_dir,
          unicorn_conf       => $puppet::params::unicorn_conf,
          unicorn_socket     => $puppet::params::unicorn_socket,
          unicorn_pid        => $puppet::params::unicorn_pid,
          unicorn_flags      => $unicorn_flags,
          webserver_frontend => $webserver_frontend,
        }
        class { '::puppet::master::passenger':
          ensure => 'stopped',
          enable => false,
          before => Class['puppet::master::unicorn'],
        }
      }
      'passenger': {
        class { '::puppet::master::webrick':
          ensure               => 'stopped',
          enable               => false,
          master_service_name  => $master_service_name,
          master_service_flags => $master_service_flags,
          before               => Class['puppet::master::passenger'],
        }
        class { '::puppet::master::unicorn':
          ensure             => 'stopped',
          enable             => false,
          rubyversion        => $rubyversion,
          rubyunicorn        => $puppet::params::rubyunicorn,
          unicorn_workers    => $unicorn_workers,
          unicorn_package    => $puppet::params::unicorn_package,
          config_dir         => $config_dir,
          unicorn_conf       => $puppet::params::unicorn_conf,
          unicorn_socket     => $puppet::params::unicorn_socket,
          unicorn_pid        => $puppet::params::unicorn_pid,
          unicorn_flags      => $unicorn_flags,
          webserver_frontend => $webserver_frontend,
          before             => Class['puppet::master::passenger'],
        }
        class { '::puppet::master::passenger':
          ensure => 'running',
          enable => true,
        }

      }
      default: {
        fail("${::modulename}: master must be one of 'webrick', 'unicorn', or 'passenger'")
      }
    }
  } else {
    class { '::puppet::master::webrick':
      ensure               => 'stopped',
      enable               => false,
      master_service_name  => $master_service_name,
      master_service_flags => $master_service_flags,
    }
    class { '::puppet::master::unicorn':
      ensure             => 'stopped',
      enable             => false,
      rubyversion        => $rubyversion,
      rubyunicorn        => $puppet::params::rubyunicorn,
      unicorn_workers    => $unicorn_workers,
      unicorn_package    => $puppet::params::unicorn_package,
      config_dir         => $config_dir,
      unicorn_conf       => $puppet::params::unicorn_conf,
      unicorn_socket     => $puppet::params::unicorn_socket,
      unicorn_pid        => $puppet::params::unicorn_pid,
      unicorn_flags      => $unicorn_flags,
      webserver_frontend => $webserver_frontend,
    }
    class { '::puppet::master::passenger':
      ensure => 'stopped',
      enable => false,
    }
  }

  class { '::puppet::install':
    package_name                 => $package_name,
    package_ensure               => $package_ensure,
    msgpack_package_name         => $msgpack_package_name,
    enable_msgpack_serialization => $enable_msgpack_serialization,
  }

  class { '::puppet::config':
    enable_msgpack_serialization   => $enable_msgpack_serialization,
    preferred_serialization_format => $preferred_serialization_format,
    configtimeout                  => $configtimeout,
    server                         => $server,
    config_defaultsfile            => $config_defaultsfile
  }

  if $service_name {
    class { '::puppet::service':
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
