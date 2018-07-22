# cert.pp --- Define puppet-openssl::cert
#
# @summary Manage an X.509 certificate file in PEM format
#
# @example Install the 'imap' cert in the default location
#
#   openssl::cert { 'imap': }
#
# @example Install the 'postgresql' cert using application specific defaults
#
#   openssl::cert { 'postgresql':
#     cert       => $::hostname,
#     cert_owner => 'root',
#     cert_group => 'postgres',
#     cert_mode  => '0444',
#     cert_dir   => '/etc/postgresql',
#     source     => $::hostname,
#   }
#
# @param ensure
# @param cert
# @param source
# @param cert_chain
# @param extension
# @param makehash
# @param cert_mode
# @param cert_owner
# @param cert_group
# @param cert_dir
# @param cert_file
#
#
define openssl::cert (
  Enum['present','absent']       $ensure     = 'present',
  String                         $cert       = $name,
  String                         $source     = $name,
  Array[String]                  $cert_chain = [],
  String                         $extension  = 'crt',
  Boolean                        $makehash   = false,
  Stdlib::Filemode               $cert_mode  = '0444',
  String                         $cert_owner = 'root',
  Optional[String]               $cert_group = undef,
  Optional[Stdlib::Absolutepath] $cert_dir   = undef,
  Optional[Stdlib::Absolutepath] $cert_file  = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $_cert_dir  = pick($cert_dir, $::openssl::default_cert_dir)
  $_cert_file = pick($cert_file, "${_cert_dir}/${cert}.${extension}")

  if ($ensure == 'present') {
    concat { $_cert_file:
      owner          => $cert_owner,
      group          => pick($cert_group, $::openssl::root_group),
      mode           => $cert_mode,
      backup         => false,
      show_diff      => false,
      ensure_newline => true,
      require        => Package['openssl'],
    }

    concat::fragment { "${_cert_file}-cert":
      target  => $_cert_file,
      content => file("${::openssl::cert_source_directory}/${source}.crt"),
      order   => '10',
    }

    #
    # Install certificate chain if used
    #

    $cert_chain.each |$index, $entry| {
      $order = sprintf('%02d', 20 + $index)

      concat::fragment { "${_cert_file}-${order}":
        target  => $_cert_file,
        content => file("${::openssl::cert_source_directory}/${entry}.crt"),
        order   => $order,
      }
    }

    #
    # Create a hash for the installed certificate. The hash must be
    # calculated on the client, since openssl implementation before 1.0.0
    # used a different hash algorithm.
    #
    # Hash collisions are not handled by this implementation (all hashed are
    # created with a .0 suffix).
    #
    # The '-f' option seems to be valid on major operatings systems (AIX,
    # Solaris, FreeBSD, Linux). This may need more work on other operating
    # systems.
    #

    if $makehash {
      $genhash = "openssl x509 -hash -noout -in ${_cert_file}"
      $command = "ln -s -f ${_cert_file} `${genhash}`.0"

      exec { "openssl rehash ${_cert_file}":
        command     => $command,
        provider    => 'shell',
        cwd         => '/',
        path        => [ '/bin', '/usr/bin', '/usr/local/bin', ],
        logoutput   => false,
        refreshonly => true,
        subscribe   => Concat[$_cert_file],
      }
    }
  }
  else {
    file { $_cert_file:
      ensure => absent,
    }
  }
}
