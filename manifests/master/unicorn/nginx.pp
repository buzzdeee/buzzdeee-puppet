# private class, do not use directly.
# takes care about nginx configuration in the unicorn case
class puppet::master::unicorn::nginx (
$ensure,
$unicorn_socket_chrooted,
$manage_vhost,
) {


  require puppet::master::unicorn

  if $ensure == 'present' {
    include ::nginx
  }

  if $manage_vhost {
    $vhosts = hiera_hash('nginx::vhosts', false)
    if $vhosts {
      $vhost_names = keys($vhosts)
      if 'puppet' in $vhost_names {
        $real_manage_vhost = false
      } else {
        $real_manage_vhost = true
      }
    }
  } else {
    $real_manage_vhost = $manage_vhost
  }

  if $real_manage_vhost {
    ::nginx::resource::vhost { 'puppet':
      ensure             => $ensure,
      listen_port        => '8140',
      ipv6_enable        => true,
      ssl                => true,
      ssl_port           => '8140',
      ssl_cert           => $::settings::hostcert,
      ssl_key            => $::settings::hostprivkey,
      server_name        => [ 'puppet', "puppet.${::fqdn}", ],
      access_log         => '/var/www/logs/puppet_access.log',
      error_log          => '/var/www/logs/puppet_error.log',
      vhost_cfg_append   => {
        ssl_crl                => $::settings::cacrl,
        ssl_client_certificate => $::settings::localcacert,
        ssl_verify_client      => 'optional',
        ssl_verify_depth       => '1',
        root                   => '/var/empty',
      },
      proxy              => 'http://puppetmaster_unicorn',
      proxy_read_timeout => '120',
      proxy_set_header   => [ 'Host $host',
                              'X-Real-IP $remote_addr',
                              'X-Forwarded-For $proxy_add_x_forwarded_for',
                              'X-Client-Verify $ssl_client_verify',
                              'X-Client-DN $ssl_client_s_dn',
                              'X-SSL-Issuer $ssl_client_i_dn', ],
    }
  }

  ::nginx::resource::upstream { 'puppetmaster_unicorn':
    ensure                => $ensure,
    members               => [ "unix:${unicorn_socket_chrooted}", ],
    upstream_fail_timeout => '0',
  }

  

}
