# Class: clm::config
# ===========================
#
# CLM server configuration class
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
# * `java_opts`
#   The options that will be passed into Java when clm-server is being
#   started
#
#   Type: string
#   Default: -Xmx1024m -XX:MaxPermSize=128m
#
# * `clm_config_file`
#   The clm-server configuration file location.
#
#   Type: string
#   Default: /etc/clm-config.yml
#
# * `clm_environment_file`
#   The environment script file location.
#
#   Type: string
#   Default: /etc/sysconfig/clm-server on RedHat based systems
#            /etc/default/clm-server on Debian based systems
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
class clm::config (
  $clm_config,
  $clm_group,
  $clm_user,
  $clm_user_home,
  $java_opts,
  $clm_config_file,
  $clm_environment_file,
) {
  # since we aren't using assert_private because of not knowing how to
  # test using rspec when it's set we need to be extra paranoid and
  # revalidate all the params
  validate_hash($clm_config)
  validate_string($clm_group)
  validate_string($clm_user)
  validate_absolute_path($clm_user_home)
  validate_absolute_path($clm_config_file)
  validate_absolute_path($clm_environment_file)
  validate_string($java_opts)

  file { $clm_config_file:
    ensure  => file,
    owner   => $clm_user,
    group   => $clm_group,
    mode    => '0600',
    content => template("${module_name}/config.yml.erb"),
  }

  file { $clm_environment_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/clm-server.sysconfig.erb")
  }
}
