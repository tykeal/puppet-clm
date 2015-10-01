# clm

[![Build Status](https://travis-ci.org/tykeal/puppet-clm.png)](https://travis-ci.org/tykeal/puppet-clm)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with clm](#setup)
    * [What clm affects](#what-clm-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with clm](#beginning-with-clm)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Installs Sonatype CLM Server

## Setup

### What clm affects

### Setup Requirements

 * `maestrodev/wget`
 * `puppetlabs/stdlib`
 * java (recommend installing via `puppetlabs/java`)

## Usage

This module is designed to do automatic hiera lookups. It should "just
work" without needing to set anything as long as you (a) have java
installed on the system in some manner and (b) want to install version
1.16.0-02 of CLM. This module does not open any firewall ports or setup
any sort of web server proxy front end.

A basic profile for use with CLM would be as follows this will install
CLM using all the default values from the clm::params class. This will
end up installing version 1.16.0-02 of CLM (latest as of when this
module was written)

```puppet
class profile::clm {
    # java is required for clm use puppet-java (or something similar)
    include ::java

    include ::clm
}
```
## Reference

 * `clm_config`
   A hash of configuration values that will be put into the config.yml
   that clm-server uses. This module creates the configuration file as
   /etc/clm-config.yml and this hash may (by default) merged into the
   `clm::params::clm_default_config` hash with this one taking
   precedence. If `merge_with_default_config` is set to false then only
   this hash will be used.

   NOTE: if you add an option that exists in the default config and you
   are merging then unless you have installed the deeper-merge gem and
   have your merge policy configured properly you will have to
   completely replicate a block to from the default into your config if
   you desire to change an option

   NOTE: No validity checking of options is currently handled. The only
   exeception to this rule is if `work_dir_manage` is set to true (the
   default) then an option of sonatypeWork *must* exist in the hash as an
   absolute path

   *Type*: hash
   *Default*: {}

 * `clm_group`
   The user group that the clm-server will be running as

   *Type*: string
   *Default*: clm-server

 * `clm_user`
   The user that the clm-server will be running as

   *Type*: string
   *Default*: clm-server

 * `clm_user_home`
   The home directory for clm-server to utilize

   *Type*: absolute path (string)
   *Default*: /opt/clm-server

 * `clm_manage_user_home`
   If the module should be setting managehome on the user object. That
   is, should the user object be informing puppet to create the home
   directory if it does not exist and set permissions appropriately

   *Type*: boolean
   *Default*: true

 * `download_site`
   The base URL that should be used for downloading clm-server

   *Type*: string
   *Default*: http://download.sonatype.com/clm/server

 * `java_opts`
   The options that will be passed into Java when clm-server is being
   started

   *Type*: string
   *Default*: -Xmx1024m -XX:MaxPermSize=128m

 * `log_dir`
   The default log location

   *Type*: absolute path (string)
   *Default*: /var/log/clm-server

 * `manage_log_dir`
   Should the module create the log dir

   *Type*: boolean
   *Default*: true

 * `manage_user`
   If the module should be creating the user and group.

   *Type*: boolean
   *Default*: true

 * `revision`
   The two revision string used by Sonatype in their releases

   *Type*: string matching the regex /^\d+$/
   *Default*: 02
   *NOTE*: The default is 02 as the current version of clm-server that is
   out at the time of module creation is at revision 02

 * `version`
   The version string used by Sonatype in their releases

   *Type*: string matching the regex /^\d+\.\d+\.\d+$/
   *Default*: 1.16.0
   *NOTE*: The default is 1.16.0 as the current version of clm-server
   that is out at the time of module creation is at version 1.16.0

 * `work_dir_manage`
   Should the module manage / create the workdir

   *Type*: boolean
   *Default*: true

 * `work_dir_recurse`
   If `work_dir_manage` should the ownership settings be recursively set
   down the tree. You may, or may not desire this

   *Type*: boolean
   *Default*: true

 * `merge_with_default_config`
   Should the `clm_config` that is passed to the module be merged with
   what the this params class declares as the defaults?

   *Type*: boolean
   *Default*: true


## Limitations

This module has only been testing RedHat / CentOS 6 & 7

## Development

To contribute please send a pull request against
https://github.com/tykeal/puppet-clm.git

