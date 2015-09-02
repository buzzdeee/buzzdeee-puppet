# private class, do not use directly.
# takes care of puppet master configuration,
# when puppet is using its internal webrick server.
class puppet::master::webrick (
$ensure,
$enable,
$master_service_name,
$master_service_flags,
) {
  service { $master_service_name:
    ensure => $ensure,
    enable => $enable,
    flags  => $master_service_flags,
  }
}
