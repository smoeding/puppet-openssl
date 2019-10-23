# @summary Manage an X.509 key file in PEM format
#
# @example Install the 'imap' key in the default location
#
#   openssl::key { 'imap': }
#
# @example Install the 'postgresql' key using application specific defaults
#
#   openssl::key { 'postgresql':
#     key     => $::hostname,
#     owner   => 'root',
#     group   => 'postgres',
#     mode    => '0440',
#     key_dir => '/etc/postgresql',
#     source  => $::hostname,
#   }
#
# @param ensure
#   The state of the resource.
#
# @param key
#   The basename of the file where the key will be stored on the client. The
#   full filename will be created using the three components `key_dir`, `key`
#   and `extension`.
#
# @param source
#   The basename of the file where the key is stored on the server. The full
#   filename will be created using the three parameters
#   `cert_source_directory` (see the base class `openssl`), `source` and
#   `source_extension`.
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
# @param key_dir
#   The destination directory on the client where the key will be stored.
#
#
define openssl::key (
  Enum['present','absent']       $ensure           = 'present',
  String                         $key              = $name,
  String                         $source           = $name,
  String                         $extension        = 'key',
  String                         $source_extension = 'key',
  Stdlib::Filemode               $mode             = '0400',
  String                         $owner            = 'root',
  Optional[String]               $group            = undef,
  Optional[Stdlib::Absolutepath] $key_dir          = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $_key_dir  = pick($key_dir, $::openssl::default_key_dir)
  $_key_file = "${_key_dir}/${key}.${extension}"

  $content = $ensure ? {
    'present' => file("${::openssl::cert_source_directory}/${source}.${source_extension}"),
    default   => undef,
  }

  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent',
  }

  file { $_key_file:
    ensure    => $_ensure,
    owner     => $owner,
    group     => pick($group, $::openssl::root_group),
    mode      => $mode,
    content   => $content,
    backup    => false,
    show_diff => false,
  }
}
