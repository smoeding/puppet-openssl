# init.pp --- Class openssl
#
# @summary Manage X.509 certificates, keys and Diffie-Hellman parameter files
#
# @example Declaring the class
#
#   class { 'openssl':
#     cert_source_directory => '/etc/puppetlabs/code/private/certs',
#     root_ca_certs         => [ 'ACME-Root-CA' ],
#   }
#
# @param cert_source_directory
#   The directory on the Puppetmaster where all certificate and key files are
#   kept. Every certificate or key file will be read from this directory and
#   then deployed on the client. This directory is accessed using the 'file'
#   function and therefore does not need to be part of the Puppet directory
#   structure. But obviously the directory and the files must be readable by
#   the Puppet user. This parameter is mandatory and has no default.
#
# @param default_key_dir
#   The default directory where a key file is deployed. This is operating
#   system specific. On Debian this is '/etc/ssl/private' and on RedHat this
#   is '/etc/pki/tls/private'.
#
# @param default_cert_dir
#   The default directory where a certificate file is deployed. This is
#   operating system specific. On Debian this is '/etc/ssl/certs' and on
#   RedHat this is '/etc/pki/tls/certs'.
#
# @param package_name
#   The name of the openssl package to install. Default value: 'openssl'.
#
# @param package_ensure
#   The desired package state. Default value: 'installed'.
#
# @param root_group
#   The group used for deployed files. This is operating system specific. On
#   Linux this is normally 'root'. On FreeBSD this is 'wheel'.
#
# @param ca_certs
#   An array of CA certificates that are installed by default. Default: []
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

  unless empty($ca_certs) {
    ::openssl::cert { $ca_certs:
      makehash => true,
    }
  }
}
