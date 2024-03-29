# @summary Manage X.509 certificates, keys and Diffie-Hellman parameter files
#
# @example Declaring the class
#
#   class { 'openssl':
#     cert_source_directory => '/etc/puppetlabs/code/private/certs',
#   }
#
# @example Declaring the class and deploy a CA certificate
#
#   class { 'openssl':
#     cert_source_directory => '/etc/puppetlabs/code/private/certs',
#     root_ca_certs         => [ 'ACME-Root-CA' ],
#   }
#
# @param cert_source_directory
#   The directory on the Puppetmaster where all certificate and key files are
#   kept. Every certificate or key file will be read from this directory and
#   then deployed on the client. This directory is accessed using the `file`
#   function and therefore does not need to be part of the Puppet directory
#   structure. But obviously the directory and the files must be readable by
#   the Puppet user. This parameter is mandatory and has no default.
#
# @param default_key_dir
#   The default directory where a key file is deployed. This is operating
#   system specific. On Debian this is `/etc/ssl/private` and on RedHat this
#   is `/etc/pki/tls/private`.
#
# @param default_cert_dir
#   The default directory where a certificate file is deployed. This is
#   operating system specific. On Debian this is `/etc/ssl/certs` and on
#   RedHat this is `/etc/pki/tls/certs`.
#
# @param package_name
#   The name of the OpenSSL package to install.
#
# @param package_ensure
#   The desired package state.
#
# @param root_group
#   The group used for deployed files. This is operating system specific. On
#   Linux this is normally `root`. On FreeBSD this is `wheel`.
#
# @param ca_certs
#   An array of CA certificates that are installed by default. Internally
#   this uses the `openssl::cert` defined type.
#
#
class openssl (
  Stdlib::Absolutepath $cert_source_directory,
  Stdlib::Absolutepath $default_key_dir,
  Stdlib::Absolutepath $default_cert_dir,
  String               $package_name,
  String               $package_ensure,
  String               $root_group,
  Array[String]        $ca_certs,
) {
  package { 'openssl':
    ensure => $package_ensure,
    name   => $package_name,
  }

  if ($facts['os']['family'] == 'Debian') {
    exec { 'openssl::update-ca-certificates':
      command     => 'update-ca-certificates',
      user        => 'root',
      cwd         => '/',
      path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin',],
      refreshonly => true,
    }
  }
  elsif ($facts['os']['family'] == 'RedHat') {
    exec { 'openssl::update-ca-trust':
      command     => 'update-ca-trust extract',
      user        => 'root',
      cwd         => '/',
      path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin',],
      refreshonly => true,
    }
  }

  unless empty($ca_certs) {
    openssl::cacert { $ca_certs: }
  }
}
