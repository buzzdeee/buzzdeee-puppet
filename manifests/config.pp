# private class, do not use directly
# takes care about the Puppet configuration

class puppet::config (
  $preferred_serialization_format,
  $runinterval,
  $configtimeout,
  $server,
  $enable_msgpack_serialization,
  $config_defaultsfile,
) {

  if $configtimeout {
    ini_setting { 'agent_configtimeout':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'agent',
      setting => 'configtimeout',
      value   => $configtimeout,
    }
  }

  if $runinterval {
    ini_setting { 'agent_runinterval':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'agent',
      setting => 'runinterval',
      value   => $runinterval,
    }
  }

  if $server {
    ini_setting { 'agent_server':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'agent',
      setting => 'server',
      value   => $server,
    }
  }

  if $enable_msgpack_serialization {
    ini_setting { 'main_preferred_serialization_format':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'main',
      setting => 'preferred_serialization_format',
      value   => $preferred_serialization_format,
    }
  }

  if $config_defaultsfile {
    # everything important is set in the puppet.conf
    file { $config_defaultsfile:
      content => '';
    }
  }

}
