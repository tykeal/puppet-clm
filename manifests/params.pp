# Class: clm::params
# ===========================
#
# Default parameters for the clm init class
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
# * `use_revision`
#   With at least Nexus IQ v1.19.0 (possibly initial release of 1.18.0) the
#   bundle revision doesn't exist in the upstream file name. This allows us to
#   flag if the revision should be used or not
#
#   Type: boolean
#   Default: true
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
# * `clm_default_config`
#   A configuration hash detailing the defaults configuration that will
#   be put into the config.yml that clm-server uses. This module
#   creates the configuration file as /etc/clm-config.yml and this hash
#   is the defaults as appropriate based upon the how this module is
#   designed and what version 1.16.0-02 of clm-server uses
#
#   Type: hash
#   Default: see definition
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
class clm::params {
  $clm_group            = 'clm-server'
  $clm_user             = 'clm-server'
  $clm_user_home        = '/opt/clm-server'
  $clm_manage_user_home = true
  $download_site        = 'http://download.sonatype.com/clm/server'
  $java_opts            = '-Xmx1024m -XX:MaxPermSize=128m'
  $log_dir              = '/var/log/clm-server'
  $manage_log_dir       = true
  $manage_user          = true

  # Current version as of the original module creation
  $revision      = '02'
  $use_revision  = true
  $version       = '1.16.0'

  $work_dir_manage  = true
  $work_dir_recurse = true

  $merge_with_default_config = true
  # DEFAULT CONFIGURATION - defaults from 1.16.0-02
  $clm_default_config = {
    'sonatypeWork'  => '/srv/clm-server',
    'http'          => {
      'port'        => '8070',
      'adminPort'   => '8071',
      'requestLog'  => {
        'console'   => {
          'enabled' => false,
        },
        'file'                         => {
          'enabled'                    => true,
          'currentLogFilename'         => '/var/log/clm-server/request.log',
          # lint:ignore:80chars
          'archivedLogFilenamePattern' => '/var/log/clm-server/request-%d.log.gz',
          # lint:endignore
          'archivedFileCount'          => '5',
        },
      },
    },
    # lint:ignore:80chars
    'logging'                                                             => {
      'level'                                                             => 'DEBUG',
      'loggers'                                                           => {
        'com.sonatype.insight.scan'                                       => 'INFO',
        'eu.medsea.mimeutil.MimeUtil2'                                    => 'INFO',
        'org.apache.http'                                                 => 'INFO',
        'org.apache.http.wire'                                            => 'ERROR',
        'org.eclipse.birt.report.engine.layout.pdf.font.FontConfigReader' => 'WARN',
        'org.eclipse.jetty'                                               => 'INFO',
        'org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter' => 'INFO',
      },
      'console'     => {
        'enabled'   => true,
        'threshold' => 'INFO',
        'logFormat' => "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n",
      },
      'file'                         => {
        'enabled'                    => true,
        'threshold'                  => 'ALL',
        'currentLogFilename'         => '/var/log/clm-server/clm-server.log',
        'archivedLogFilenamePattern' => '/var/log/clm-server/clm-server-%d.log.gz',
        'archivedFileCount'          => '5',
        'logFormat'                  => "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n",
      },
    },
    # lint:endignore
  }
}
