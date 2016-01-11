# private class, do not use directly.
# takes care of puppet master configuration,
# when puppet is using its internal webrick server.
class puppet::master::webrick (
$ensure,
$enable,
$master_service_name,
$master_service_flags,
$master_package,
) {

  if $master_package {
    package { $master_package:

    }
  }

  service { $master_service_name:
    ensure    => $ensure,
    enable    => $enable,
    flags     => $master_service_flags,
    subscribe => Class['puppet::config']
  }
}
