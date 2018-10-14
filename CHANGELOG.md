## 2018-08-05 - Release 1.2.0

### Features

- Implement an additional parameter `source_extension` for the `openssl::cert` and `openssl::key` defined types. This parameter sets the file extension for certificates (default: `crt`) and keys (default: `key`) on the server.

- The version requirements for the `stdlib` and `concat` modules have been updated.

## 2018-08-05 - Release 1.1.0

### Bugfixes

- The initial release was missing the default hiera configuration for Ubuntu. This release uses the operating system family to load the hiera configuration. Ubuntu is therefore handled as a member of the Debian family.

## 2018-07-27 - Release 1.0.0

### Summary

Initial release.
