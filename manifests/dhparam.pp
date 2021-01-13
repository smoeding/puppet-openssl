# @summary Manage Diffie-Hellman parameter files
#
# @example Create a parameter file using default parameters
#
#   openssl::dhparam { '/etc/ssl/dhparam.pem': }
#
# @example Create a parameter file using 4096 bits
#
#   openssl::dhparam { '/etc/ssl/dhparam.pem':
#     bits => '4096',
#   }
#
# @example Create a parameter file using non-default permissions
#
#   openssl::dhparam { '/etc/ssl/dhparam.pem':
#     owner => 'www-data',
#     group => 'www-data',
#     mode  => '0640',
#   }
#
# @param ensure
#   The state of the resource.
#
# @param file
#   The file name where the DH parameters are stored on the node. Must be an
#   absolute path.
#
# @param bits
#   The number of bits to generate.
#
# @param generator
#   The generator to use. Check the OpenSSL documentation for details about
#   this parameter.
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
#
define openssl::dhparam (
  Enum['present','absent']   $ensure    = 'present',
  Stdlib::Absolutepath       $file      = $name,
  Enum['2048','4096','8192'] $bits      = '2048',
  Enum['2','5']              $generator = '2',
  Stdlib::Filemode           $mode      = '0644',
  String                     $owner     = 'root',
  Optional[String]           $group     = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  # Create DH parameter file
  if ($ensure == 'present') {
    openssl_genparam { $file:
      ensure    => $ensure,
      algorithm => 'DH',
      bits      => $bits,
      generator => $generator,
      before    => File[$file],
    }
  }

  # Manage file owner/group/mode
  file { $file:
    ensure => $ensure,
    owner  => $owner,
    group  => pick($group, $::openssl::root_group),
    mode   => $mode,
  }
}
