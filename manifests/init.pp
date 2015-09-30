# Class: clm
# ===========================
#
# Installs, configures and manages Sonatype CLM server
#
# This module does _not_ manage anything inside CLM server that is not
# configurable in the config file
#
# Parameters
# ----------
#
# * `clm_config`
#   A hash of configuration values that will be put into the config.yml
#   that clm-server uses. This module creates the configuration file as
#   /etc/clm-config.yml and this hash may (by default) merged into the
#   `clm::params::clm_default_config` hash with this one taking
#   precedence. If merge_with_default_config is set to false then only
#   this hash will be used.
#
#   NOTE: if you add an option that exists in the default config and you
#   are merging then unless you have installed the deeper-merge gem and
#   have your merge policy configured properly you will have to
#   completely replicate a block to from the default into your config if
#   you desire to change an option
#
#   NOTE: No validity checking of options is currently handled. The only
#   exeception to this rule is if `work_dir_manage` is set to true (the
#   default) then an option of sonatypeWork *must* exist in the hash as an
#   absolute path
#
# * `clm_group`
#   The user group that the clm-server will be running as
#
#   Type: string
#   Default: clm-server
#
# * `clm_user`
#   The user that the clm-server will be running as
#
#   Type: string
#   Default: clm-server
#
# * `clm_user_home`
#   The home directory for clm-server to utilize
#
#   Type: absolute path (string)
#   Default: /opt/clm-server
#
# * `clm_manage_user_home`
#   If the module should be setting managehome on the user object. That
#   is, should the user object be informing puppet to create the home
#   directory if it does not exist and set permissions appropriately
#
#   Type: boolean
#   Default: true
#
# * `download_site`
#   The base URL that should be used for downloading clm-server
#
#   Type: string
#   Default: http://download.sonatype.com/clm/server
#
# * `java_opts`
#   The options that will be passed into Java when clm-server is being
#   started
#
#   Type: string
#   Default: -Xmx1024m -XX:MaxPermSize=128m
#
# * `log_dir`
#   The default log location
#
#   Type: absolute path (string)
#   Default: /var/log/clm-server
#
# * `manage_log_dir`
#   Should the module create the log dir
#
#   Type: boolean
#   Default: true
#
# * `manage_user`
#   If the module should be creating the user and group.
#
#   Type: boolean
#   Default: true
#
# * `revision`
#   The two revision string used by Sonatype in their releases
#
#   Type: string matching the regex /^\d+$/
#   Default: 02
#   NOTE: The default is 02 as the current version of clm-server that is
#   out at the time of module creation is at revision 02
#
# * `version`
#   The version string used by Sonatype in their releases
#
#   Type: string matching the regex /^\d+\.\d+\.\d+$/
#   Default: 1.16.0
#   NOTE: The default is 1.16.0 as the current version of clm-server
#   that is out at the time of module creation is at version 1.16.0
#
# * `work_dir_manage`
#   Should the module manage / create the workdir
#
#   Type: boolean
#   Default: true
#
# * `work_dir_recurse`
#   If work_dir_manage should the ownership settings be recursively set
#   down the tree. You may, or may not desire this
#
#   Type: boolean
#   Default: true
#
# * `merge_with_default_config`
#   Should the clm_config that is passed to the module be merged with
#   what the this params class declares as the defaults?
#
#   Type: boolean
#   Default: true
#
# Variables
# ----------
#
# None
#
# Examples
# --------
#
# @example
#   class { 'clm': }
#
# @example
#   class { 'clm':
#     clm_config        => {
#       http            => {
#         'port'        => '8080',
#         'adminPort'   => '8081',
#         'requestLog'  => {
#           'console'   => {
#             'enabled' => false,
#           },
#         },
#       },
#       file                         => {
#         enabled                    => true,
#         currentLogFileName         => '/var/log/clm-server/request.log',
#         archivedLogFilenamePattern => '/var/log/clm-server/request-%d.log.gz',
#         archivedFileCount          => '5',
#       },
#     },
#   }
#
# Authors
# -------
#
# Andrew J Grimberg <agrimberg@linuxfoundation.org>
#
# Copyright
# ---------
#
# Copyright 2015 Andrew J Grimberg
#
class clm (
  $clm_config                = {},
  $clm_group                 = $clm::params::clm_group,
  $clm_user                  = $clm::params::clm_user,
  $clm_user_home             = $clm::params::clm_user_home,
  $clm_manage_user_home      = $clm::params::clm_manage_user_home,
  $download_site             = $clm::params::download_site,
  $java_opts                 = $clm::params::java_opts,
  $log_dir                   = $clm::params::log_dir,
  $manage_log_dir            = $clm::params::manage_log_dir,
  $manage_user               = $clm::params::manage_user,
  $merge_with_default_config = $clm::params::merge_with_default_config,
  $revision                  = $clm::params::revision,
  $version                   = $clm::params::version,
  $work_dir_manage           = $clm::params::work_dir_manage,
  $work_dir_recurse          = $clm::params::work_dir_recurse,
) inherits clm::params {
  validate_hash($clm_config)
  validate_string($clm_group)
  validate_string($clm_user)
  validate_absolute_path($clm_user_home)
  validate_bool($clm_manage_user_home)
  validate_string($download_site)
  validate_string($java_opts)
  validate_absolute_path($log_dir)
  validate_bool($manage_log_dir)
  validate_bool($manage_user)
  validate_bool($merge_with_default_config)
  validate_re($revision, '^\d+$')
  validate_re($version, '^\d+\.\d+\.\d+$')
  validate_bool($work_dir_manage)
  validate_bool($work_dir_recurse)

  anchor { 'clm::begin': }
  anchor { 'clm::end': }

  if ($manage_user) {
    group { $clm_group:
      ensure => present,
    }

    user { $clm_user:
      ensure     => present,
      comment    => 'CLM User',
      gid        => $clm_group,
      home       => $clm_user_home,
      managehome => $clm_manage_user_home,
      shell      => '/bin/sh', # required to start application properly
      system     => true,
      require    => Group[$clm_group],
      before     => Class['clm::install'],
    }
  }

  if ($merge_with_default_config) {
    $real_config = merge($clm::params::clm_default_config, $clm_config)
  } else {
    $real_config = $clm_config
  }

  class { 'clm::install':
    clm_config       => $real_config,
    clm_group        => $clm_group,
    clm_user         => $clm_user,
    clm_user_home    => $clm_user_home,
    download_site    => $download_site,
    log_dir          => $log_dir,
    manage_log_dir   => $manage_log_dir,
    revision         => $revision,
    version          => $version,
    work_dir_manage  => $work_dir_manage,
    work_dir_recurse => $work_dir_recurse,
  }

  class { 'clm::config':
    clm_config    => $real_config,
    clm_group     => $clm_group,
    clm_user      => $clm_user,
    clm_user_home => $clm_user_home,
    java_opts     => $java_opts,
    revision      => $revision,
    version       => $version,
  }

  class { 'clm::service':
    clm_group     => $clm_group,
    clm_user      => $clm_user,
    clm_user_home => $clm_user_home,
  }

  Anchor['clm::begin'] ->
    Class['clm::install'] ->
    Class['clm::config'] ~>
    Class['clm::service'] ->
  Anchor['clm::end']
}
