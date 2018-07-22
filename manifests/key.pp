# key.pp --- Define openssl::key
#
# @summary Manage an X.509 key file in PEM format
#
# @example Install the 'imap' key in the default location
#
#   openssl::key { 'imap': }
#
# @example Install the 'postgresql' key using application specific defaults
#
#   openssl::key { 'postgresql':
#     key       => $::hostname,
#     key_owner => 'root',
#     key_group => 'postgres',
#     key_mode  => '0440',
#     key_dir   => '/etc/postgresql',
#     source    => $::hostname,
#   }
#
# @param ensure
# @param key
# @param source
# @param extension
# @param key_mode
# @param key_owner
# @param key_group
# @param key_dir
# @param key_file
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

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

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
