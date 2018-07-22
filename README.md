# openssl

[![Build Status](https://travis-ci.org/smoeding/puppet-openssl.svg?branch=master)](https://travis-ci.org/smoeding/puppet-openssl)
[![Puppet Forge](http://img.shields.io/puppetforge/v/stm/openssl.svg)](https://forge.puppetlabs.com/stm/openssl)
[![License](https://img.shields.io/github/license/smoeding/puppet-openssl.svg)](https://raw.githubusercontent.com/smoeding/puppet-openssl/master/LICENSE)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with openssl](#setup)
    * [What openssl affects](#what-openssl-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage X.509 certificates, keys and Diffie-Hellman parameter files.

## Module Description

The `openssl` module manages files containing X.509 certificates and keys. In contrast to some other modules, this module does not generate the certificates and keys itself. Instead it requires a directory on the Puppet server where the certificates and keys can be fetched from.

## Setup

### What openssl affects

The modules installs the openssl package and provides defined types to manage certificates, keys and Diffie-Hellman parameter files on the nodes.

### Setup Requirements

The module requires the Puppetlabs modules `stdlib` and `concat`.

### Beginning with openssl

The module needs to be initialized before you can manage certificates and keys.

``` puppet
class { 'openssl':
 cert_source_directory => '/etc/puppetlabs/code/private/certs',
}
```

The parameter `cert_source_directory` is mandatory and has no default value. This is the directory on the Puppet server where you keep your certificates and keys. This directory does not need to be inside a Puppet environment directory (e.g. below `/etc/puppetlabs/code/environments/production`). It can be located anywhere on the Puppet server. But the content must by readable by the user running the Puppetserver application (normally `puppet`). So make sure the filesystem permissions are set correctly.

The module expects to find certificate and key files in this directory. Example:

``` text
# ls -l /etc/puppetlabs/code/private/certs/
total 236
-r-------- 1 puppet root 1509 May 25  2017 cloud.crt
-r-------- 1 puppet root 1675 May 25  2017 cloud.key
-r-------- 1 puppet root 1472 Mar 18  2016 columbia.crt
-r-------- 1 puppet root 1671 Mar 18  2016 columbia.key
-r-------- 1 puppet root 1484 Oct  9  2015 evora.crt
-r-------- 1 puppet root 1679 Oct  9  2015 evora.key
-r-------- 1 puppet root 1570 Mar  1 20:06 imap.crt
-r-------- 1 puppet root 1679 Mar  1 20:06 imap.key
-r-------- 1 puppet root 1647 May 27 05:17 letsencrypt-ca.crt
-r-------- 1 puppet root 1464 Sep 25  2015 xmpp.crt
-r-------- 1 puppet root 1675 Sep 25  2015 xmpp.key
```

## Usage

### Install Root CA certificates by default

If you want to provide certain Root CA certificates by default, you can add a class parameter containing the list of certificate names:

``` puppet
class { 'openssl':
  cert_source_directory => '/etc/puppetlabs/code/private/certs',
  ca_certs              => [ 'letsencrypt-ca' ],
}
```

This would install the Let's Encrypt certificate stored in the `letsencrypt-ca.crt` file. For CA certificates the module automatically creates hashes pointing to the installed file. On a Debian client node this would create the following file and link:

``` text
lrwxrwxrwx 1 root root   18 Jul 14 13:27 /etc/ssl/certs/4f06f81d.0 -> letsencrypt-ca.crt
-r--r--r-- 1 root root 1647 May 17 09:09 /etc/ssl/certs/letsencrypt-ca.crt
```

### Install a certificate and key

``` puppet
openssl::cert { 'imap': }
openssl::key { 'imap': }
```

``` text
r-------- 1 root root 1679 Jan  3  2017 /etc/ssl/private/imap.key
r--r--r-- 1 root root 1570 Mar  1 20:07 /etc/ssl/certs/imap.crt
```

## Reference

### Classes

#### Class: `openssl`

##### Parameters

* `ensure`
* `cert`
* `source`
* `cert_chain`
* `extension`
* `makehash`
* `cert_mode`
* `cert_owner`
* `cert_group`
* `cert_dir`
* `cert_file`

### Defined Types

#### `openssl::cert`

* `ensure`
* `cert`
* `source`
* `cert_chain`
* `extension`
* `makehash`
* `cert_mode`
* `cert_owner`
* `cert_group`
* `cert_dir`
* `cert_file`

#### `openssl::key`

* `ensure`
* `key`
* `source`
* `extension`
* `key_mode`
* `key_owner`
* `key_group`
* `key_dir`
* `key_file`

#### `openssl::dhparam`

* `ensure`
* `file`
* `bits`
* `generator`
* `mode`
* `owner`
* `group`

## Limitations

## Development

Feel free to send pull requests for new features.
