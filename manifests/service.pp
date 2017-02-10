# Class: clm::service
# ===========================
#
# CLM server service management class
#
# Parameters
# ----------
#
# None
#
# Variables
# ----------
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
class clm::service (
  $clm_group,
  $clm_user,
  $clm_user_home,
  $clm_config_file,
  $clm_environment_file,
) {
  # since we aren't using assert_private because of not knowing how to
  # test using rspec when it's set we need to be extra paranoid and
  # revalidate all the params
  validate_string($clm_group)
  validate_string($clm_user)
  validate_absolute_path($clm_user_home)

  # Determine if it should be a systemd.service or an init.d service
  case $::osfamily {
    'RedHat': {
      case $::operatingsystem {
        'Fedora': {
          if versioncmp($::operatingsystemrelease, '14') >= 0 {
            $init_target   = '/usr/lib/systemd/system/clm-server.service'
            $init_template = "${module_name}/clm-server.service.erb"
          } else {
            # We aren't actually going to support SysV setup right now
            # If we do, this will likely need to be moved to clm::config
            fail('SysV systems are not currently supported by this module')
          }
        }
        default: {
          if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
            $init_target   = '/usr/lib/systemd/system/clm-server.service'
            $init_template = "${module_name}/clm-server.service.erb"
          } else {
            # We aren't actually going to support SysV setup right now
            # If we do, this will likely need to be moved to clm::config
            fail('SysV systems are not currently supported by this module')
          }
        }
      }
    }
    'Debian' : {
      $init_target   = '/etc/systemd/system/clm-server.service'
      $init_template = "${module_name}/clm-server.service.erb"
    }
    # We default to expecting a systemd.service
    default: {
      $init_target   = '/usr/lib/systemd/system/clm-server.service'
      $init_template = "${module_name}/clm-server.service.erb"
    }
  }

  file { 'clm-server-init':
    ensure  => file,
    path    => $init_target,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($init_template),
    notify  => Service['clm-server'],
  }

  service { 'clm-server':
    ensure  => running,
    enable  => true,
    require => File['clm-server-init'],
  }
}

