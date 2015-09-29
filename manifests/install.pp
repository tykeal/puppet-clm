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
# None
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
}
