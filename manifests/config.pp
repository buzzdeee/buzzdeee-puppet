# private class, do not use directly
# takes care about the Puppet configuration

class puppet::config (
  $autosign,
  $parser,
  $config_defaultsfile,
  $enable_msgpack_serialization,
  $preferred_serialization_format,
  $disable_warnings,
  $runinterval,
  $configtimeout,
  $stringify_facts,
  $server,
  $syslogfacility,
  $puppet_env,
  $service_ensure,
  $dbhost,
  $dbuser,
  $dbpass,
  $dbname,
  $dbtable,
  $puppet_group,
  $include_legacy_facts,
) {

  if $configtimeout {
    ini_setting { 'agent_configtimeout':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'agent',
      setting => 'configtimeout',
      value   => $configtimeout,
    }
  }

  if $include_legacy_facts {
    ini_setting { 'include_legacy_facts':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'include_legacy_facts',
      value   => $include_legacy_facts,
    }
  }

  if $runinterval {
    ini_setting { 'agent_runinterval':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'agent',
      setting => 'runinterval',
      value   => $runinterval,
    }
  }

  if $server {
    ini_setting { 'agent_server':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'agent',
      setting => 'server',
      value   => $server,
    }
  }

  if $autosign {
    ini_setting { 'main_autosign':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'autosign',
      value   => $autosign,
    }

    file { $autosign:
      owner   => 'root',
      group   => $puppet_group,
      mode    => '0550',
      content => template('puppet/signing_policy.erb'),
    }
  }

  if $parser {
    ini_setting { 'main_parser':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'parser',
      value   => $parser,
    }
  }

  if $syslogfacility {
    ini_setting { 'main_syslogfacility':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'syslogfacility',
      value   => $syslogfacility,
    }
  }

  if $stringify_facts {
    ini_setting { 'main_stringify_facts':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'stringify_facts',
      value   => $stringify_facts,
    }
  }

  if $enable_msgpack_serialization {
    ini_setting { 'main_preferred_serialization_format':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'preferred_serialization_format',
      value   => $preferred_serialization_format,
    }
  }

  if $disable_warnings {
    ini_setting { 'main_disable_warnings':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'disable_warnings',
      value   => $disable_warnings,
    }
  }

  if $puppet_env {
    ini_setting { 'main_environment':
      ensure  => 'present',
      path    => $::puppet_config,
      section => 'main',
      setting => 'environment',
      value   => $puppet_env,
    }
  }

  if $config_defaultsfile {
    # everything important is set in the puppet.conf
    # However, Ubuntu needs an explicit START
    if $service_ensure == 'running' {
      $defaults_contents = $::operatingsystem ? {
        'Ubuntu' => 'START=yes',
        default  => '',
      }
    } else {
      $defaults_contents = $::operatingsystem ? {
        'Ubuntu' => 'START=no',
        default  => '',
      }
    }
    file { $config_defaultsfile:
      content => $defaults_contents,
    }
  }

}
