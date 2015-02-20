class puppet::service (
  $service_ensure,
  $service_enable,
  $service_name,
  $service_flags,
  $service_provider,
) {
  service { $service_name:
    ensure   => $service_ensure,
    enable   => $service_enable,
    flags    => $service_flags,
    provider => $service_provider,
  }
}
