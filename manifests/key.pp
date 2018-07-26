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
#     key     => $::hostname,
#     owner   => 'root',
#     group   => 'postgres',
#     mode    => '0440',
#     key_dir => '/etc/postgresql',
#     source  => $::hostname,
#   }
#
# @param ensure
#   The state of the resource. Can be 'present' or 'absent'. Default value:
#   'present'.
#
# @param key
#   The basename of the file where the key will be stored on the client. The
#   full filename will be created using the three components 'key_dir', 'key'
#   and 'extension'.
#
# @param source
#   The basename of the file where the key is stored on the server. The full
#   filename will be created using the two parameters 'cert_source_directory'
#   (see the base class 'openssl') and 'source'. The extension is currently
#   hardcoded as '.key'.
#
# @param extension
#   The file extension used for files created on the client. Default: 'key'.
#
# @param mode
#   The file mode used for the resource. Default value: '0400'.
#
# @param owner
#   The file owner used for the resource. Default value: 'root'.
#
# @param group
#   The file group used for the resource. The default value is operating
#   system dependent.
#
# @param key_dir
#   The destination directory on the client where the key will be stored. The
#   default value is operating system specific.
#
#
define openssl::key (
  Enum['present','absent']       $ensure    = 'present',
  String                         $key       = $name,
  String                         $source    = $name,
  String                         $extension = 'key',
  Stdlib::Filemode               $mode      = '0400',
  String                         $owner     = 'root',
  Optional[String]               $group     = undef,
  Optional[Stdlib::Absolutepath] $key_dir   = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $_key_dir  = pick($key_dir, $::openssl::default_key_dir)
  $_key_file = "${_key_dir}/${key}.${extension}"

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
    owner     => $owner,
    group     => pick($group, $::openssl::root_group),
    mode      => $mode,
    content   => $content,
    backup    => false,
    show_diff => false,
  }
}
