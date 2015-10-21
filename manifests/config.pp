# private class, do not use directly
# takes care about the Puppet configuration

class puppet::config (
  $autosign,
  $config_defaultsfile,
  $enable_msgpack_serialization,
  $preferred_serialization_format,
  $runinterval,
  $configtimeout,
  $server,
  $puppet_env,
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

  if $autosign {
    ini_setting { 'main_autosign':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'main',
      setting => 'autosign',
      value   => $autosign,
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

  if $puppet_env {
    ini_setting { 'main_environment':
      ensure  => 'present',
      path    => '/etc/puppet/puppet.conf',
      section => 'main',
      setting => 'environment',
      value   => $puppet_env,
    }
  }

  if $config_defaultsfile {
    # everything important is set in the puppet.conf
    file { $config_defaultsfile:
      content => '';
    }
  }

}
