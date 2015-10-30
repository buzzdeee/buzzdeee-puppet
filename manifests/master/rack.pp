# Private class, do not use directly
# takes care of setting up the config.ru for passenger and 
# unicorn servers

class puppet::master::rack (
  $user,
  $group,
  $file,
  $ensure,
) {

  $path = dirname($file)

  file { $path:
    owner  => $user,
    group  => $group,
    mode   => '0755',
    ensure => 'directory',
    
  }

  file { $file:
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('puppet/config.ru.erb'),
  }

}
