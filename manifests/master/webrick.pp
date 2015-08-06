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
