class puppet::master::unicorn (
$ensure,
$enable,
$unicorn_workers,
$unicorn_package,
$config_dir,
$unicorn_socket,
$unicorn_pid,
$unicorn_flags,
$webserver_frontend,
) {
  package { $unicorn_package:
    ensure => 'installed',
  }

  if $ensure == 'running' {
    $files_ensure = 'file'
  } else {
    $files_ensure = 'absent'
  }

  file { "/etc/rc.d/puppetmaster_unicorn":
    ensure  => $files_ensure,
    owner   => 'root',
    group   => '0',
    mode    => '0444',
    content => template('puppet/puppetmaster_unicorn.erb'),
  }

  file { "/etc/rc.d/puppetmaster_unicorn":
    ensure  => $files_ensure,
    owner   => 'root',
    group   => '0',
    mode    => '0444',
    content => template('puppet/puppetmaster_unicorn.erb'),
  }

  service { 'puppetmaster_unicorn':
    ensure => $ensure,
    enable => $enable,
    flags  => $unicorn_flags,
  }

  Package[$unicorn_package] -> 
  File['/etc/rc.d/puppetmaster_unicorn'] ~>
  Service['puppetmaster_unicorn']

}
