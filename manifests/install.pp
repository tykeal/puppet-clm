# Class: clm::install
# ===========================
#
# CLM server installation class
#
# Parameters
# ----------
#
# None
#
# Variables
# ----------
#
# * `clm_config`
#   A hash of configuration values that will be put into the config.yml
#   that clm-server uses. This module creates the configuration file as
#   /etc/clm-config.yml and this hash is the final merging of the
#   `clm::params::clm_default_config` and the user supplied
#   configuration hash if `merge_with_default_config` was set to true
#   (default) in the base class.
#
#   NOTE: if you add an option that exists in the default config and you
#   are merging then unless you have installed the deeper-merge gem and
#   have your merge policy configured properly you will have to
#   completely replicate a block to from the default into your config if
#   you desire to change an option
#
#   Type: hash
#   Default: see clm::params for the base defaults
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
# * `download_site`
#   The base URL that should be used for downloading clm-server
#
#   Type: string
#   Default: http://download.sonatype.com/clm/server
#
# * `manage_log_dir`
#   Should the module create the log dir
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
class clm::install (
  $clm_config,
  $clm_group,
  $clm_user,
  $clm_user_home,
  $download_site,
  $log_dir,
  $manage_log_dir,
  $revision,
  $version,
  $work_dir_manage,
  $work_dir_recurse,
) {
  # since we aren't using assert_private because of not knowing how to
  # test using rspec when it's set we need to be extra paranoid and
  # revalidate all the params
  validate_hash($clm_config)
  validate_string($clm_group)
  validate_string($clm_user)
  validate_absolute_path($clm_user_home)
  validate_string($download_site)
  validate_absolute_path($log_dir)
  validate_bool($manage_log_dir)
  validate_re($revision, '^\d+$')
  validate_re($version, '^\d+\.\d+\.\d+$')
  validate_bool($work_dir_manage)
  validate_bool($work_dir_recurse)

  $full_version = "${version}-${revision}"
  $clm_archive  = "sonatype-clm-server-${full_version}-bundle.tar.gz"
  $download_url = "${download_site}/${clm_archive}"
  $dl_file      = "${clm_user_home}/${clm_archive}"
  $clm_extract  = "${clm_user_home}/sonatype-clm-server-${full_version}"
  $extract_file = "${clm_extract}/sonatype-clm-server-${full_version}.jar"
  $clm_link     = "${clm_user_home}/clm-server"

  wget::fetch{ $clm_archive:
    source      => $download_url,
    destination => $dl_file,
    before      => Exec['clm-untar'],
  }

  file { $clm_extract:
    ensure  => directory,
    owner   => $clm_user,
    group   => $clm_group,
    recurse => true,
    before  => Exec['clm-untar'],
  }

  exec { 'clm-untar':
    command => "tar zxf ${dl_file}",
    cwd     => $clm_extract,
    creates => $extract_file,
    path    => ['/bin','/usr/bin'],
  }

  file { $clm_link:
    ensure  => link,
    target  => $clm_extract,
    require => Exec['clm-untar'],
  }

  if ($work_dir_manage) {
    # Technically this matters for everything, but for the module it only
    # matters if we're managing the work dir
    if (has_key($clm_config, 'sonatypeWork')) {
      $work_dir = $clm_config['sonatypeWork']
    } else {
      fail('A sonatypeWork configuraiton entry must exist in your clm_config')
    }

    file { $work_dir:
      ensure  => directory,
      owner   => $clm_user,
      group   => $clm_group,
      recurse => $work_dir_recurse,
      require => Exec['clm-untar'],
    }
  }

  if ($manage_log_dir) {
    file { 'clm-server-log':
      ensure => directory,
      path   => $log_dir,
      owner  => $clm_user,
      group  => $clm_group,
      mode   => '0700',
    }
  }
}
