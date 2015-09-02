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
$config_dir,
$unicorn_conf,
$unicorn_socket,
$unicorn_pid,
$unicorn_flags,
$webserver_frontend,
) {

  if $ensure == 'running' {
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
                  ensure         => $webserver_frontend_ensure,
                  unicorn_socket => $unicorn_socket,
                }
      }
      default: { fail("${::module_name}: webserver_frontend ${webserver_frontend} not supported with unicorn") }
    }
  }

  file { '/etc/rc.d/puppetmaster_unicorn':
    ensure  => $files_ensure,
    owner   => 'root',
    group   => '0',
    mode    => '0555',
    content => template('puppet/puppetmaster_unicorn.erb'),
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

  # The unicorn_flags are passed into the rc script directly,
  # no reason to pass them in to the service again.
  # further that breaks in the case of $ensure != running, since
  # the service tries to set the flags, but the rc script won't
  # be available, and then the catalog apply error at that point
  # on every run :(
  service { 'puppetmaster_unicorn':
    ensure => $ensure,
    enable => $enable,
  }

  File[$unicorn_conf] ~>
  File['/etc/rc.d/puppetmaster_unicorn'] ~>
  Service['puppetmaster_unicorn']
}
