# @summary Manage Diffie-Hellman parameter files.
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
#   The state of the resource. Can be `present` or `absent`. Default value:
#   `present`.
#
# @param file
#   The file name where the DH parameters are stored on the node. Must be an
#   absolute path. Default value: the resource title.
#
# @param bits
#   The number of bits to generate. Must be one of the strings `2048`, `4096`
#   or `8192`. Defaults to `2048`.
#
# @param generator
#   The generator to use. Must be the string `2` or `5`. Check the openssl
#   documentation for details about this parameter. Default value: `2`.
#
# @param mode
#   The file mode used for the resource. Default value: `0644`.
#
# @param owner
#   The file owner used for the resource. Default value: `root`.
#
# @param group
#   The file group used for the resource. The default value is operating
#   system dependent.
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

  if ($ensure == 'present') {

    # Create parameter file unless it already exists
    exec { "openssl dhparam -out ${file} -${generator} ${bits}":
      creates => $file,
      timeout => '1800',        # really slow machines
      path    => [ '/bin', '/usr/bin', '/usr/local/bin', ],
      before  => File[$file],
    }

    # Manage file owner/group/mode
    file { $file:
      ensure => file,
      owner  => $owner,
      group  => pick($group, $::openssl::root_group),
      mode   => $mode,
    }
  }
  else {
    file { $file:
      ensure => absent,
    }
  }
}
