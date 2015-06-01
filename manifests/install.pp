# private class, do not use directly
# takes care about installing puppet and dependencies
class puppet::install (
  $package_ensure,
  $package_name,
  $msgpack_package_name,
  $enable_msgpack_serialization,
) {
  package { $package_name:
    ensure => $package_ensure,
  }

  if $enable_msgpack_serialization and $msgpack_package_name {
    package { $msgpack_package_name:
      ensure => $package_ensure,
    }

  }

}
