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
class clm::params {
  $clm_group            = 'clm-server'
  $clm_user             = 'clm-server'
  $clm_user_home        = '/opt/clm-server'
  $clm_manage_user_home = true
  $download_site        = 'http://download.sonatype.com/clm/server'
  $java_opts            = '-Xmx1024m -XX:MaxPermSize=128m'
  $manage_user          = true

  # Current version as of the original module creation
  $revision      = '02'
  $version       = '1.16.0'

  $work_dir_manage  = true
  $work_dir_recurse = true

  $merge_with_default_config = true
  # DEFAULT CONFIGURATION - defaults from 1.16.0-02
  $clm_default_config = {
    'sonatypeWork'  => '/srv/sonatype-work/clm-server',
    'http'          => {
      'port'        => '8070',
      'adminPort'   => '8071',
      'requestLog'  => {
        'console'   => {
          'enabled' => false,
        },
        'file'                         => {
          'enabled'                    => true,
          'currentLogFileName'         => '/var/log/clm-server/request.log',
          # lint:ignore:80chars
          'archivedLogFilenamePattern' => '/var/log/clm-server/request-%d.log.gz',
          # lint:endignore
          'archivedFileCount'          => '5',
        },
      },
    },
    # lint:ignore:80chars
    'logging'                                                              => {
      'level'                                                              => 'DEBUG',
      'loggers'                                                            => {
        'com.sonatype.insight.scan'                                        => 'INFO',
        # lint:ignore:2sp_soft_tabs
         'eu.medsea.mimeutil.MimeUtil2'                                    => 'INFO',
         'org.apache.http'                                                 => 'INFO',
         'org.apache.http.wire'                                            => 'ERROR',
         'org.eclipse.birt.report.engine.layout.pdf.font.FontConfigReader' => 'WARN',
         'org.eclipse.jetty'                                               => 'INFO',
         'org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter' => 'INFO',
        # lint:endignore
      },
    },
    # lint:endignore
    'console'     => {
      'enabled'   => true,
      'threshold' => 'INFO',
      # lint:ignore:80chars
      'logFormat' => "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n",
      # lint:endignore
    },
    'file'                         => {
      'enabled'                    => true,
      'threshold'                  => 'ALL',
      'currentLogFileName'         => '/var/log/clm-server/clm-server.log',
      # lint:ignore:80chars
      'archivedLogFilenamePattern' => '/var/log/clm-server/clm-server-%d.log.gz',
      'archivedFileCount'          => '5',
      'logFormat'                  => "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n",
      # lint:endignore
    },
  }
}
