# = Define: openssl::key
#
# Install a certificate key file in PEM format
#
# == Parameters:
#
# [*ensure*]
#   Default: present
#
# == Requires:
#
# Nothing.
#
# == Sample Usage:
#
#   openssl::key { 'my-root-ca': }
#
#
define openssl::key (
  Enum['present','absent']       $ensure    = 'present',
  String                         $key       = $name,
  String                         $source    = $name,
  String                         $extension = 'key',
  Stdlib::Filemode               $key_mode  = '0400',
  String                         $key_owner = 'root',
  Optional[String]               $key_group = undef,
  Optional[Stdlib::Absolutepath] $key_dir   = undef,
  Optional[Stdlib::Absolutepath] $key_file  = undef,
) {
  include ::openssl

  $_key_dir  = pick($key_dir, $::openssl::default_key_dir)
  $_key_file = pick($key_file, "${_key_dir}/${key}.${extension}")

  $content = $ensure ? {
    'present' => file("${::openssl::cert_source_directory}/${source}.key"),
    default   => undef,
  }

  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }

  file { $_key_file:
    ensure    => $_ensure,
    owner     => $key_owner,
    group     => pick($key_group, $::openssl::root_group),
    mode      => $key_mode,
    content   => $content,
    backup    => false,
    show_diff => false,
    require   => Package['openssl'],
  }
}
