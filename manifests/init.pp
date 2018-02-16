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
# @param default_key_dir
#   The default directory where a key file is deployed. This is operating
#   system specific.
#
# @param default_cert_dir
#   The default directory where a certificate file is deployed. This is
#   operating system specific.
#
# @param cert_source_directory
#   The directory on the Puppetmaster where all certificate and key files are
#   kept. Every certificate or key file will be read from this directory and
#   the deployed on the client. This directory is accessed using the `file'
#   function and therefore does not need to be part of the Puppet directory
#   structure. But obviously the directory and the files must be readable by
#   the Puppet user.
#
# @param package_name
#   The name of the openssl package to install.
#
# @param package_ensure
#
# @param root_group
#
# @param ca_certs
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
