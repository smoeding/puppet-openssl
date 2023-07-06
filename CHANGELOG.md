## 2023-07-06 - Release 4.0.0

### Breaking changes

- Drop Support for Puppet 6

### Features

- Add support for Puppet 8
- Add support for Concat 9.x and Stdlib 9.x
- New types to create OpenSSL keys, CSRs, certificates and DHparams have been added. They should be considered beta for now.

## 2023-04-20 - Release 3.4.1

### Features

- Add support for Concat 8.x

## 2022-02-25 - Release 3.4.0

### Features

- The OpenSSL config file to generate a CSR can now be generated on it's own using the new defined type `openssl::config`.
- Add new data type `Openssl::Extendedkeyusage`.

## 2022-02-16 - Release 3.3.0

### Features

- Support additional choices for the number of bits in RSA keys

## 2021-09-01 - Release 3.2.0

### Features

- Add support for Stdlib 8.x.
- Add support for FreeBSD 13
- Add support for Debian 11

### Bug Fixes

- Fix error propagation in custom types.  A custom type now fails as it should if an error condition occurs while creating the resource.

## 2021-03-09 - Release 3.1.0

### Features

- Add support for Puppet 7.
- Add support for Stdlib 7.x.

## 2020-12-09 - Release 3.0.0

### Breaking changes

- Removed Support for Debian-8, Ubuntu-14.04, CentOS-6, RedHat-6 and FreeBSD-10
- The parameter `manage_trust` for the defined type `openssl::cert` has been removed. CA certificates should be managed using the `openssl::cacert` defined type.
- The class parameter `openssl::ca_certs` internally uses the `openssl::cacert` defined type.

### Features

- Add Support for FreeBSD-12
- On RedHat based distributions the defined type `openssl::cacert` will keep all CA certificates in `/etc/pki/ca-trust/source/anchors` and also call the `update-ca-trust` script.

## 2020-10-14 - Release 2.2.0

### Features

- Add support for Ubuntu 20.04
- Add new defined type `openssl::cacert` to install a trusted CA certificate. The parameter `manage_trust` for the defined type `openssl::cert` is now deprecated and will be removed in the next major version.

## 2019-11-03 - Release 2.1.0

### Features

- Add support for Debian-10, CentOS-8, RedHat-8.

### Bugfixes

- Fix `openssl_version` fact to handle versions without a trailing letter.

## 2019-10-09 - Release 2.0.0

### Breaking changes

- Remove support for Puppet 4.
- For the `openssl::cert` defined type the attribute `makehash` has been replaced by the more general attribute `manage_trust`. On RedHat based distributions the certificate will now be added to the system-wide NSS database when this parameter is `true`.

### Enhancements

- Add support for Stdlib 6.x.
- Add support for Concat 6.x.
- Add new custom type `openssl_hash` to manage symbolic links using a certificate hash as name.
- Add new custom type `openssl_certutil` to manage certificates in the system-wide NSS database.

## 2019-02-23 - Release 1.4.0

### Summary

- Add documentation in the REFERENCE.md file.

## 2018-10-14 - Release 1.3.0

### Features

- Support Puppet 6

## 2018-10-14 - Release 1.2.0

### Features

- Implement an additional parameter `source_extension` for the `openssl::cert` and `openssl::key` defined types. This parameter sets the file extension for certificates (default: `crt`) and keys (default: `key`) on the server.

- The version requirements for the `stdlib` and `concat` modules have been updated.

## 2018-08-05 - Release 1.1.0

### Bugfixes

- The initial release was missing the default hiera configuration for Ubuntu. This release uses the operating system family to load the hiera configuration. Ubuntu is therefore handled as a member of the Debian family.

## 2018-07-27 - Release 1.0.0

### Summary

Initial release.
