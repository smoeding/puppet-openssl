# dhparam.pp --- Define openssl::dhparam
#
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
# @param file
# @param bits
# @param generator
# @param mode
# @param owner
# @param group
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
      require => Package['openssl'],
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
