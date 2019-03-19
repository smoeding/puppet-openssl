# @summary Manage OpenSSL certificate signing request (CSR)
#
# @example Creating a CSR with subject alternate names
#
#   openssl::csr { 'www.example.com':
#     csr_file                    => '/etc/ssl/www.example.com.csr',
#     cnf_file                    => '/etc/ssl/www.example.com.cnf',
#     csr_file                    => '/etc/ssl/www.example.com.key',
#     subject_alternate_names_dns => [ 'www.example.com', 'example.com', ],
#   }
#
# @param csr_file
#   The full path name of the signing request file that will be created. It
#   contains the attributes that will be included in the certificate and also
#   the public part of the key.
#
# @param cnf_file
#   The full path name of the OpenSSL configuration file that will be
#   created. It contains a minimal set of configuration options that are
#   needed to process the CSR. It will also be used when the CSR is used to
#   create a self-signed certificate. Updates to the config file will not
#   trigger the generation of a new certificate.
#
# @param key_file
#   The full path of the private key file. This file including the key must
#   already be present to generate the CSR.
#
# @param common_name
#   The value of the X.509 CN attribute. This attribute is mandatory.
#
# @param subject_alternate_names_dns
#   An array of DNS names that will be added as subject alternate names using
#   the 'DNS' prefix. The certificate can be used for all names given in this
#   list. Normally the common name should be in this list or the certificate
#   may be rejected by modern web browsers.
#
# @param subject_alternate_names_ip
#   An array of IP addresses that wull be added as subject alternate names
#   using the 'IP' prefix. The certificate can be used for all IP addresses
#   given in this list.
#
# @param key_usage
#   The intended purposes of the certificate.
#
# @param extended_key_usage
#   The extended key usage of the certificate.
#
# @param basic_constraints_ca
#   Whether the subject of the certificate is a CA.
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
# @param country_name
#   The value of the X.509 `C` attribute.
#
# @param state_or_province_name
#   The value of the X.509 `ST` attribute.
#
# @param locality_name
#   The value of the X.509 `L` attribute.
#
# @param postal_code
#   The value of the X.509 `PC` attribute.
#
# @param street_address
#   The value of the X.509 `STREET` attribute.
#
# @param organization_name
#   The value of the X.509 `O` attribute.
#
# @param organization_unit_name
#   The value of the X.509 `OU` attribute.
#
#
define openssl::csr (
  Stdlib::Absolutepath       $csr_file,
  Stdlib::Absolutepath       $cnf_file,
  Stdlib::Absolutepath       $key_file,
  String                     $common_name                 = $name,
  Array[Stdlib::Fqdn]        $subject_alternate_names_dns = [],
  Array[Stdlib::IP::Address] $subject_alternate_names_ip  = [],
  Array[Openssl::Keyusage]   $key_usage                   = [ 'keyEncipherment', 'dataEncipherment' ],
  Array[String]              $extended_key_usage          = [ 'serverAuth' ],
  Boolean                    $basic_constraints_ca        = false,
  Stdlib::Filemode           $mode                        = '0444',
  String                     $owner                       = 'root',
  Optional[String]           $group                       = undef,
  Optional[String]           $country_name                = undef,
  Optional[String]           $state_or_province_name      = undef,
  Optional[String]           $locality_name               = undef,
  Optional[String]           $postal_code                 = undef,
  Optional[String]           $street_address              = undef,
  Optional[String]           $organization_name           = undef,
  Optional[String]           $organization_unit_name      = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $use_subject_alternate_names = !empty($subject_alternate_names_dns) or
    !empty($subject_alternate_names_ip)

  $basic_constraints = bool2str($basic_constraints_ca, 'CA:true', 'CA:false')

  $params = {
    'common_name'                 => $common_name,
    'country_name'                => $country_name,
    'state_or_province_name'      => $state_or_province_name,
    'locality_name'               => $locality_name,
    'postal_code'                 => $postal_code,
    'street_address'              => $street_address,
    'organization_name'           => $organization_name,
    'organization_unit_name'      => $organization_unit_name,
    'key_usage'                   => $key_usage,
    'extended_key_usage'          => $extended_key_usage,
    'basic_constraints'           => $basic_constraints,
    'subject_alternate_names_dns' => $subject_alternate_names_dns,
    'subject_alternate_names_ip'  => $subject_alternate_names_ip,
    'use_subject_alternate_names' => $use_subject_alternate_names,
  }

  file { $cnf_file:
    ensure  => file,
    owner   => $owner,
    group   => pick($group, $::openssl::root_group),
    mode    => '0600',
    content => epp("${module_name}/csr.conf.epp", $params),
  }

  exec { "openssl req -new -config ${cnf_file} -key ${key_file} -out ${csr_file}":
    creates => $csr_file,
    path    => [ '/bin', '/usr/bin', '/usr/local/bin', ],
    require => File[$cnf_file],
    before  => File[$csr_file],
  }

  file { $csr_file:
    ensure => file,
    owner  => $owner,
    group  => pick($group, $::openssl::root_group),
    mode   => $mode,
  }
}
