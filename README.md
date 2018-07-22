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

## Setup

### What openssl affects

The modules installs the openssl package and manages certificates, keys and Diffie-Hellman parameter files on the node.

### Setup Requirements

The module requires the Puppetlabs modules `stdlib` and `concat`.

## Usage

## Reference

### Classes

#### Class: `openssl`

##### Parameters (all optional)

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
#### `openssl::key`
#### `openssl::dhparam`

## Limitations

## Development

Feel free to send pull requests for new features.
