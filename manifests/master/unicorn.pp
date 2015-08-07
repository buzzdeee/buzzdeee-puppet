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

  case $webserver_frontend {
    'nginx': { class { '::puppet::master::unicorn::nginx':
                  ensure         => $webserver_frontend_ensure,
                  unicorn_socket => $unicorn_socket,
                }
    }
    default: { fail("${::modulename}: webserver_frontend ${webserver_frontend} not supported with unicorn") }
  }

  file { '/etc/rc.d/puppetmaster_unicorn':
    ensure  => $files_ensure,
    owner   => 'root',
    group   => '0',
    mode    => '0555',
    content => template('puppet/puppetmaster_unicorn.erb'),
  }

  file { $unicorn_conf:
    ensure  => $files_ensure,
    owner   => 'root',
    group   => '0',
    mode    => '0444',
    content => template('puppet/unicorn.conf.erb'),
  }

  service { 'puppetmaster_unicorn':
    ensure => $ensure,
    enable => $enable,
    flags  => $unicorn_flags,
  }

  File[$unicorn_conf] ~>
  File['/etc/rc.d/puppetmaster_unicorn'] ~>
  Service['puppetmaster_unicorn']
}
