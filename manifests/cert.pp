# @summary Manage an X.509 certificate file in PEM format
#
# @example Install the 'imap' cert in the default location
#
#   openssl::cert { 'imap': }
#
# @example Install the 'postgresql' cert using application specific defaults
#
#   openssl::cert { 'postgresql':
#     cert     => $facts['networking']['hostname'],
#     owner    => 'root',
#     group    => 'postgres',
#     mode     => '0444',
#     cert_dir => '/etc/postgresql',
#     source   => $facts['networking']['hostname'],
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
# @param extension
#   The file extension used for files created on the client.
#
# @param source_extension
#   The file extension used for files read on the server.
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
  Stdlib::Filemode               $mode             = '0444',
  String                         $owner            = 'root',
  Optional[String]               $group            = undef,
  Optional[Stdlib::Absolutepath] $cert_dir         = undef,
) {
  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $_cert_dir  = pick($cert_dir, $openssl::default_cert_dir)
  $_cert_file = "${_cert_dir}/${cert}.${extension}"

  if ($ensure == 'present') {
    concat { $_cert_file:
      owner          => $owner,
      group          => pick($group, $openssl::root_group),
      mode           => $mode,
      backup         => false,
      show_diff      => false,
      ensure_newline => true,
    }

    concat::fragment { "${_cert_file}-cert":
      target  => $_cert_file,
      content => file("${openssl::cert_source_directory}/${source}.${source_extension}"),
      order   => '10',
    }

    #
    # Install certificate chain if used
    #

    $cert_chain.each |$index, $entry| {
      $order = sprintf('%02d', 20 + $index)

      concat::fragment { "${_cert_file}-${order}":
        target  => $_cert_file,
        content => file("${openssl::cert_source_directory}/${entry}.${source_extension}"),
        order   => $order,
      }
    }
  }
  else {
    file { $_cert_file:
      ensure => $ensure,
    }
  }
}
