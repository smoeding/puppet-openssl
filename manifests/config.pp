# @summary Create OpenSSL config for a CSR
#
# @example Creating a config file for a CSR
#
#   openssl::config { '/etc/ssl/www.example.com.cnf':
#     common_name        => 'www.example.com',
#     extended_key_usage => [ 'serverAuth', 'clientAuth' ],
#   }
#
# @param common_name
#   The value of the X.509 `CN` attribute. This attribute is mandatory.
#
# @param config
#   The full path name of the OpenSSL configuration file that will be
#   created. It contains a minimal set of configuration options that are
#   needed to process a CSR.
#
# @param subject_alternate_names_dns
#   An array of DNS names that will be added as subject alternate names using
#   the `DNS` prefix. The certificate can be used for all names given in this
#   list. Normally the common name should be in this list or the certificate
#   may be rejected by modern web browsers.
#
# @param subject_alternate_names_ip
#   An array of IP addresses that will be added as subject alternate names
#   using the `IP` prefix. The certificate can be used for all IP addresses
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
define openssl::config (
  String                           $common_name,
  Stdlib::Absolutepath             $config                      = $name,
  Array[Stdlib::Fqdn]              $subject_alternate_names_dns = [],
  Array[Stdlib::IP::Address]       $subject_alternate_names_ip  = [],
  Array[Openssl::Keyusage]         $key_usage                   = [ 'keyEncipherment', 'dataEncipherment' ],
  Array[Openssl::Extendedkeyusage] $extended_key_usage          = [ 'serverAuth' ],
  Boolean                          $basic_constraints_ca        = false,
  String                           $owner                       = 'root',
  Optional[String]                 $group                       = undef,
  Optional[String]                 $country_name                = undef,
  Optional[String]                 $state_or_province_name      = undef,
  Optional[String]                 $locality_name               = undef,
  Optional[String]                 $postal_code                 = undef,
  Optional[String]                 $street_address              = undef,
  Optional[String]                 $organization_name           = undef,
  Optional[String]                 $organization_unit_name      = undef,
) {

  # The base class must be included first
  unless defined(Class['openssl']) {
    fail('You must include the openssl base class before using any openssl defined resources')
  }

  $use_subject_alternate_names = !empty($subject_alternate_names_dns) or
    !empty($subject_alternate_names_ip)

  $basic_constraints = bool2str($basic_constraints_ca, 'CA:true', 'CA:false')

  $params = {
    'default_bits'                => '2048',
    'default_md'                  => 'sha512',
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

  file { $config:
    ensure  => file,
    owner   => $owner,
    group   => pick($group, $::openssl::root_group),
    mode    => '0600',
    content => epp("${module_name}/csr.conf.epp", $params),
  }
}
