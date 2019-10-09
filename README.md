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

The `openssl` module manages files containing X.509 certificates and keys.

In contrast to some other modules, this module does not generate the certificates and keys itself. Instead it uses a directory on the Puppet server where the certificates and keys can be fetched from. So you can run your own CA or take certificates received from a public CA and have them managed by Puppet.

## Setup

### What openssl affects

The modules installs the openssl package and provides defined types to manage certificates, keys and Diffie-Hellman parameter files on the nodes.

### Setup Requirements

The module requires the Puppetlabs modules `stdlib` and `concat`.

### Beginning with openssl

The module must be initialized before you can manage certificates and keys:

``` puppet
class { 'openssl':
  cert_source_directory => '/etc/puppetlabs/code/private/certs',
}
```

The parameter `cert_source_directory` is mandatory and has no default value. This is a directory on the Puppet server where you keep your certificates and keys. This directory does not need to be inside a Puppet environment directory. It can be located anywhere on the Puppet server. But the content must by readable by the user running the Puppetserver application (normally `puppet`). So make sure the filesystem permissions are set correctly.

The module expects to find certificate and key files in this directory on the Puppet server. As an example the directory used above might look like this listing:

``` text
# ls -l /etc/puppetlabs/code/private/certs/
total 236
-r-------- 1 puppet root 1509 May 25  2017 cloud.crt
-r-------- 1 puppet root 1675 May 25  2017 cloud.key
-r-------- 1 puppet root 1570 Mar  1 20:06 imap.crt
-r-------- 1 puppet root 1679 Mar  1 20:06 imap.key
-r-------- 1 puppet root 1647 May 27 05:17 letsencrypt-ca.crt
-r-------- 1 puppet root 1472 Mar 18  2016 vortex.crt
-r-------- 1 puppet root 1671 Mar 18  2016 vortex.key
```

## Usage

### Install Root CA certificates by default

If you want to provide certain Root or intermediate CA certificates by default, you can add a class parameter containing the list of certificate names:

``` puppet
class { 'openssl':
  cert_source_directory => '/etc/puppetlabs/code/private/certs',
  ca_certs              => [ 'letsencrypt-ca' ],
}
```

This would install the Let's Encrypt certificate stored in the `letsencrypt-ca.crt` file. For these certificates the module automatically adds a trust attribute. On Debian based distributions a symbolic link pointing to the installed file will be created using the certificate hash as name:

``` text
lrwxrwxrwx 1 root root   18 Jul 14 13:27 /etc/ssl/certs/4f06f81d.0 -> letsencrypt-ca.crt
-r--r--r-- 1 root root 1647 May 17 09:09 /etc/ssl/certs/letsencrypt-ca.crt
```

On RedHat based distributions the `certutil` binary is used to add the certificate to the system-wide NSS database in `/etc/pki/nssdb`.

### Install a certificate and key using defaults

The two defined types `openssl::cert` and `openssl::key` can be used to install a certificate and key using all defaults:

``` puppet
openssl::cert { 'imap': }
openssl::key { 'imap': }
```

This would take the files from the directory on the Puppet server (e.g. `/etc/puppetlabs/code/private/certs` if you set that using the `cert_source_directory` parameter). On the client the two files are created with restrictive permissions and ownership:

``` text
r-------- 1 root root 1679 Jan  3  2017 /etc/ssl/private/imap.key
r--r--r-- 1 root root 1570 Mar  1 20:07 /etc/ssl/certs/imap.crt
```

The default destination directories are distribution specific and can be configured using the class parameters `default_key_dir` and `default_cert_dir`.

### Install a certificate and key for a specific application

The following code shows how to install a certificate and key in an application specific directory using application specific owner, group and mode:

``` text
openssl::key { 'postgresql':
  key     => $::hostname,
  owner   => 'root',
  group   => 'postgres',
  mode    => '0440',
  key_dir => '/etc/postgresql',
  source  => $::hostname,
}

openssl::cert { 'postgresql':
  cert     => $::hostname,
  owner    => 'root',
  group    => 'postgres',
  mode     => '0444',
  cert_dir => '/etc/postgresql',
  source   => $::hostname,
}
```

This example uses the hostname fact as the name of the key and therefore installs the cert and key on the host of the same name. If we assume that node `vortex` is your PostgreSQL server running Debian, then the following two files would be created by the manifest:

``` text
r--r----- 1 root postgres 1704 Jan  3  2017 /etc/postgresql/vortex.key
r--r--r-- 1 root postgres 1464 Jan  3  2017 /etc/postgresql/vortex.crt
```

### Create a Diffie-Hellman parameter file

To use perfect forward secrecy cipher suites, you must set up Diffie-Hellman parameters on the server. Most applications allow including these parameters using a file. You can generate such a file using the `openssl::dhparam` defined type.

Using all the defaults (2048 bits):

``` text
openssl::dhparam { '/etc/nginx/ssl/dh2048.pem': }
```

Using 4096 bits and a different file group:

``` text
openssl::dhparam { '/etc/mail/tls/dh2048.pem':
  bits  => '4096',
  group => 'smmsp',
}
```

## Reference

See [REFERENCE.md](https://github.com/smoeding/puppet-openssl/blob/master/REFERENCE.md)

## Limitations

## Development

Feel free to send pull requests for new features.
