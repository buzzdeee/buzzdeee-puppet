# private class, do not use directly
# takes care of puppet master configuration, in case
# its behind a unicorn
class puppet::master::unicorn (
$ensure,
$enable,
$rubyversion,
$rubyunicorn,
$unicorn_workers,
$unicorn_package,
$unicorn_conf,
$unicorn_socket,
$unicorn_socket_chrooted,
$unicorn_timeout,
$unicorn_pid,
$unicorn_flags,
$webserver_frontend,
$puppet_user,
$puppet_group,
$manage_vhost,
) {

  if $ensure == 'running' {

    package { "ruby${rubyversion}-rack":
      ensure => 'installed',
      before => Service['puppetmaster_unicorn'],
    }

    $files_ensure = 'file'
    $webserver_frontend_ensure = 'present'
    package { $unicorn_package:
      ensure => 'installed',
      before => File[$unicorn_conf],
    }
  } else {
    # Not uninstalling the unicorn package,
    # because others might still need/use it
    $files_ensure = 'absent'
    $webserver_frontend_ensure = 'absent'
  }

  if $webserver_frontend {
    case $webserver_frontend {
      'nginx': { class { '::puppet::master::unicorn::nginx':
                  ensure                  => $webserver_frontend_ensure,
                  unicorn_socket_chrooted => $unicorn_socket_chrooted,
                  manage_vhost            => $manage_vhost,
                }
      }
      default: { fail("${::module_name}: webserver_frontend ${webserver_frontend} not supported with unicorn") }
    }
  }

  if $enable != false {
    file { '/etc/rc.d/puppetmaster_unicorn':
      ensure  => $files_ensure,
      owner   => 'root',
      group   => '0',
      mode    => '0555',
      content => template('puppet/puppetmaster_unicorn.erb'),
    }

    # The unicorn_socket can be an IP or path,
    # path is usually fully qualified
    if $unicorn_socket and $unicorn_socket =~ /^\/.*/ {
      file { dirname($unicorn_socket):
        ensure => 'directory',
        owner  => $puppet_user,
        group  => $puppet_group,
      }
    }

    if $unicorn_conf {
      file { $unicorn_conf:
        ensure  => $files_ensure,
        owner   => 'root',
        group   => '0',
        mode    => '0444',
        content => template('puppet/unicorn.conf.erb'),
      }
    }

    class { '::puppet::master::rack':
      ensure => $files_ensure,
      user   => $puppet_user,
      group  => $puppet_group,
      file   => "${::puppet_confdir}/config.ru",
      before => Service['puppetmaster_unicorn'],
    }

    # The unicorn_flags are passed into the rc script directly,
    # no reason to pass them in to the service again.
    # further that breaks in the case of $ensure != running, since
    # the service tries to set the flags, but the rc script won't
    # be available, and then the catalog apply error at that point
    # on every run :(
    service { 'puppetmaster_unicorn':
      ensure    => $ensure,
      enable    => $enable,
      subscribe => Class['puppet::config'],
    }

    if $unicorn_conf {
      File[$unicorn_conf] ~>
      File['/etc/rc.d/puppetmaster_unicorn'] ~>
      Service['puppetmaster_unicorn']
    } else {
      File['/etc/rc.d/puppetmaster_unicorn'] ~>
      Service['puppetmaster_unicorn']
    }

    if $webserver_frontend {
      case $webserver_frontend {
        'nginx': {
          Service['puppetmaster_unicorn'] ->
          Service['nginx']
        }
        default: {
          error("${::module_name} doesn't support webserver_frontent: $webserver_frontend")
        }
      }
    }
  }
}
