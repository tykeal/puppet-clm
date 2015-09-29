# Class: clm
# ===========================
#
# Full description of class clm here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'clm':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
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
  }

  class { 'clm::service':
  }

  Anchor['clm::begin'] ->
    Class['clm::install'] ->
    Class['clm::config'] ~>
    Class['clm::service'] ->
  Anchor['clm::end']
}
