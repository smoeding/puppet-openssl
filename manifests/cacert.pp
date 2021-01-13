# @summary Manage an X.509 CA certificate file in PEM format
#
# @example Install the 'my-root-ca' trusted cert in the default location
#
#   openssl::cacert { 'my-root-ca': }
#
# @param ensure
#   The state of the resource.
#
# @param cert
#   The basename of the file where the certificate will be stored on the
#   client. The full filename will be created using the three components
#   `cert_dir`, `cert` and `extension`.
#
# @param source
#   The basename of the file where the certificate is stored on the server.
#   The full filename will be created using the three parameters
#   `cert_source_directory` (see the base class `openssl`), `source` and
#   `source_extension`.
#
# @param extension
#   The file extension used for files created on the client. This parameter
#   is ignored on Debian and RedHat based distributions as the operating
#   system specific tools require certificates to be installed using the
#   `.crt` extension.
#
# @param source_extension
#   The file extension used for files read on the server.
#
# @param mode
#   The file mode used for the resource. Note that certificate
#   verification may fail if the file permissions are too restrictive.
#
# @param owner
#   The file owner used for the resource.
#
# @param group
#   The file group used for the resource.
#
# @param cert_dir
#   The destination directory on the client where the certificate will be
#   stored. This parameter is ignored on Debian and RedHat based
#   distributions. Debian requires CA certificates to be stored in
#   `/usr/local/share/ca-certificates` and RedHat requires CA certificates
#   to be stored in `/etc/pki/ca-trust/source/anchors`.
#
#
define openssl::cacert (
  Enum['present','absent']       $ensure           = 'present',
  String                         $cert             = $name,
  String                         $source           = $name,
  String                         $extension        = 'crt',
  String                         $source_extension = 'crt',
  Stdlib::Filemode               $mode             = '0444',
  String                         $owner            = 'root',
  Optional[String]               $group            = undef,
  Optional[Stdlib::Absolutepath] $cert_dir         = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $_cert_dir =  pick($cert_dir, $::openssl::default_cert_dir)

  # Debian/RedHat require the certificate file to be stored in a fixed
  # directory using a fixed extension.
  $_cert_file = $facts['os']['family'] ? {
    'Debian' => "/usr/local/share/ca-certificates/${cert}.crt",
    'RedHat' => "/etc/pki/ca-trust/source/anchors/${cert}.crt",
    default  => "${_cert_dir}/${cert}.${extension}",
  }

  if ($ensure == 'present') {
    $content = file("${::openssl::cert_source_directory}/${source}.${source_extension}")

    case $facts['os']['family'] {
      'Debian': {
        file { $_cert_file:
          ensure  => file,
          owner   => $owner,
          group   => pick($group, $::openssl::root_group),
          mode    => $mode,
          content => $content,
          notify  => Exec['openssl::update-ca-certificates'],
        }
      }
      'FreeBSD': {
        file { $_cert_file:
          ensure  => file,
          owner   => $owner,
          group   => pick($group, $::openssl::root_group),
          mode    => $mode,
          content => $content,
        }

        # Create a hash for the installed certificate. The hash must be
        # calculated on the client, since different OpenSSL implementations
        # use different hash algorithms.

        openssl_hash { $_cert_file:
          ensure  => $ensure,
          require => File[$_cert_file],
        }
      }
      'RedHat': {
        file { $_cert_file:
          ensure  => file,
          owner   => $owner,
          group   => pick($group, $::openssl::root_group),
          mode    => $mode,
          content => $content,
          notify  => Exec['openssl::update-ca-trust'],
        }

        # Add the installed certificate to the system-wide NSS database and
        # mark it as trusted for SSL. This requires the certutil executable
        # which is generally only available on RedHat-based distributions.

        openssl_certutil { $cert:
          ensure    => $ensure,
          filename  => $_cert_file,
          ssl_trust => 'C',
          require   => File[$_cert_file],
        }
      }
      default: {
        warn("Unsupported operating system family: ${facts['os']['family']}")
      }
    }
  }
  else {
    case $facts['os']['family'] {
      'Debian': {
        file { $_cert_file:
          ensure => $ensure,
          notify => Exec['openssl::update-ca-certificates'],
        }
      }
      'FreeBSD': {
        openssl_hash { $_cert_file:
          ensure => $ensure,
          before => File[$_cert_file],
        }

        file { $_cert_file:
          ensure => $ensure,
        }
      }
      'RedHat': {
        openssl_certutil { $cert:
          ensure => $ensure,
          before => File[$_cert_file],
        }

        file { $_cert_file:
          ensure => $ensure,
          notify => Exec['openssl::update-ca-trust'],
        }
      }
      default: {
        warn("Unsupported operating system family: ${facts['os']['family']}")
      }
    }
  }
}
