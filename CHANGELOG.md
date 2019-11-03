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
