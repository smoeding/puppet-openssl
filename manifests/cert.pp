# @summary Manage an X.509 certificate file in PEM format
#
# @example Install the 'imap' cert in the default location
#
#   openssl::cert { 'imap': }
#
# @example Install the 'postgresql' cert using application specific defaults
#
#   openssl::cert { 'postgresql':
#     cert     => $::hostname,
#     owner    => 'root',
#     group    => 'postgres',
#     mode     => '0444',
#     cert_dir => '/etc/postgresql',
#     source   => $::hostname,
#   }
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
# @param cert_chain
#   An array of certificate names that are should be added to the certificate
#   file. This allows the generation of certificate chains to provide a full
#   verification path for the certificate if intermediate CAs are used. The
#   chain is included in the generated certificate file. The certificates
#   must be available in `cert_source_directory` on the server just like the
#   ordinary certificate.
#
#   This parameter can't be used if `managed_trust` is set to `true`.
#
# @param extension
#   The file extension used for files created on the client.
#
# @param source_extension
#   The file extension used for files read on the server.
#
# @param manage_trust
#   A boolean value that determines if the certificate should be marked as a
#   trusted certificate. The mark is set if the parameter value is `true` and
#   removed if the parameter value is `false`. This is mostly useful for CA
#   certificates to establish a proper trust chain.
#
#   On Debian based distributions this depends on the `openssl` class
#   parameter `use_ca_certificates`. If the parameter is `false` (the
#   default) then it is done by creating a symbolic link pointing to
#   the certificate file using the certificate hash as name. If the
#   `use_ca_certificates` parameter is `true` then the trust is
#   managed by the `ca-certificates` package. In this case the
#   certificate is installed in `/usr/local/share/ca-certificates`
#   using a `.crt` extension. The certificate hashes are created by
#   the `update-ca-certificates` script which is called automatically
#   by `openssl::cert`.
#
#   On RedHat based distributions the certificate is added to the system-wide
#   NSS database in `/etc/pki/nssdb`. The `certutil` binary is required for
#   this. The value of the parameter `cert` is used as the nickname for the
#   certificate. Do not try to add the same certificate a second time with a
#   different nickname to the database. This will fail silently and Puppet
#   will try to add the certificate on every subsequent run.
#
#   If this parameter is set to `true` then the certificate chain must
#   be empty.
#
# @param mode
#   The file mode used for the resource.
#
# @param owner
#   The file owner used for the resource.
#
# @param group
#   The file group used for the resource.
#
# @param cert_dir
#   The destination directory on the client where the certificate will be
#   stored.
#
#
define openssl::cert (
  Enum['present','absent']       $ensure           = 'present',
  String                         $cert             = $name,
  String                         $source           = $name,
  Array[String]                  $cert_chain       = [],
  String                         $extension        = 'crt',
  String                         $source_extension = 'crt',
  Boolean                        $manage_trust     = false,
  Stdlib::Filemode               $mode             = '0444',
  String                         $owner            = 'root',
  Optional[String]               $group            = undef,
  Optional[Stdlib::Absolutepath] $cert_dir         = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  if ($manage_trust and !empty($cert_chain)) {
    fail('The parameter cert_chain must be empty if manage_trust is true')
  }

  # Local scope variable to indicate if we should use ca_certificates
  $use_ca_certificates = ($::openssl::use_ca_certificates and ($facts['os']['family'] == 'Debian'))

  $_cert_dir  = pick($cert_dir, $::openssl::default_cert_dir)

  # Use static certificate directory and extension if
  # $use_ca_certificates is true
  $_cert_file = ($use_ca_certificates) ? {
    true    => "/usr/local/share/ca-certificates/${cert}.crt",
    default => "${_cert_dir}/${cert}.${extension}",
  }

  if ($ensure == 'present') {
    concat { $_cert_file:
      owner          => $owner,
      group          => pick($group, $::openssl::root_group),
      mode           => $mode,
      backup         => false,
      show_diff      => false,
      ensure_newline => true,
    }

    concat::fragment { "${_cert_file}-cert":
      target  => $_cert_file,
      content => file("${::openssl::cert_source_directory}/${source}.${source_extension}"),
      order   => '10',
    }

    #
    # Install certificate chain if used
    #

    $cert_chain.each |$index, $entry| {
      $order = sprintf('%02d', 20 + $index)

      concat::fragment { "${_cert_file}-${order}":
        target  => $_cert_file,
        content => file("${::openssl::cert_source_directory}/${entry}.${source_extension}"),
        order   => $order,
      }
    }

    if $manage_trust {
      case $facts['os']['family'] {
        'Debian': {
          if $use_ca_certificates {
            Concat[$_cert_file] ~> Exec['openssl::update-ca-certificates']
          }
          else {
            # Create a hash for the installed certificate. The hash must be
            # calculated on the client, since different openssl implementations
            # use different hash algorithms.

            openssl_hash { $_cert_file:
              ensure  => $ensure,
              require => Concat[$_cert_file],
            }
          }
        }
        'FreeBSD': {
          # Create a hash for the installed certificate. The hash must be
          # calculated on the client, since different openssl implementations
          # use different hash algorithms.

          openssl_hash { $_cert_file:
            ensure  => $ensure,
            require => Concat[$_cert_file],
          }
        }
        'RedHat': {
          # Add the installed certificate to the system-wide NSS database and
          # mark it as trusted for SSL. This requires the certutil executable
          # which is generally only available on RedHat-based distributions.

          openssl_certutil { $cert:
            ensure    => $ensure,
            filename  => $_cert_file,
            ssl_trust => 'C',
            require   => Concat[$_cert_file],
          }
        }
        default: {
          warn("Unsupported operating system family: ${facts['os']['family']}")
        }
      }
    }
  }
  else {
    if $manage_trust {
      case $facts['os']['family'] {
        'Debian': {
          if $use_ca_certificates {
            File[$_cert_file] ~> Exec['openssl::update-ca-certificates']
          }
          else {
            openssl_hash { $_cert_file:
              ensure => $ensure,
              before => File[$_cert_file],
            }
          }
        }
        'FreeBSD': {
          openssl_hash { $_cert_file:
            ensure => $ensure,
            before => File[$_cert_file],
          }
        }
        'RedHat': {
          openssl_certutil { $cert:
            ensure => $ensure,
            before => File[$_cert_file],
          }
        }
        default: {
          warn("Unsupported operating system family: ${facts['os']['family']}")
        }
      }
    }

    file { $_cert_file:
      ensure => $ensure,
    }
  }
}
