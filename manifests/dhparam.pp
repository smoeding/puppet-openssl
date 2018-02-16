# dhparam.pp --- Define openssl::dhparam
#
# @summary Manage Diffie-Hellman parameter files.
#
# @example Create a parameter file using default parameters
#
#   openssl::dhparam { '/etc/ssl/dhparam.pem': }
#
# @example Create a parameter file using using 4096 bits
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
# @param
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
  include ::openssl

  if ($ensure == 'present') {

    # Create parameter file unless it already exists

    exec { "openssl dhparam -out ${file} -${generator} ${bits}":
      creates => $file,
      timeout => '1800',        # really slow machines
      path    => [ '/bin', '/usr/bin', '/usr/local/bin', ],
      require => Package['openssl'],
      before  => File[$file],
    }
  }

  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }

  file { $file:
    ensure => $_ensure,
    owner  => $owner,
    group  => pick($group, $::openssl::root_group),
    mode   => $mode,
  }
}
