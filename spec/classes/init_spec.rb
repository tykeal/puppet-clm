require 'spec_helper'
describe 'clm', :type => :class do
  let (:facts) {
    {
      'kernel'                 => 'Linux',
      'osfamily'               => 'RedHat',
      'operatingsystem'        => 'Fedora',
      'operatingsystemrelease' => '14',
    }
  }

  context 'with defaults for all parameters' do
    it { should contain_class('clm') }
    it { should contain_class('clm::params') }

    it { should contain_group('clm-server').with(
      'ensure' => 'present',
    ) }

    it { should contain_user('clm-server').with(
      'ensure'     => 'present',
      'comment'    => 'CLM User',
      'gid'        => 'clm-server',
      'home'       => '/opt/clm-server',
      'managehome' => true,
      'shell'      => '/bin/sh',
      'system'     => true,
      'require'    => 'Group[clm-server]',
      'before'     => 'Class[Clm::Install]',
    ) }

    it { should contain_anchor('clm::begin') }
    it { should contain_class('clm::install').that_requires(
      'Anchor[clm::begin]') }
    it { should contain_class('clm::config').that_notifies(
      'Class[clm::service]').that_requires('Class[clm::install]') }
    it { should contain_class('clm::service').that_subscribes_to(
      'Class[clm::config]') }
    it { should contain_anchor('clm::end').that_requires(
      'Class[clm::service]') }
  end

  context 'default config file' do
    it { should contain_file('/etc/clm-config.yml').with_content(
"# WARNING THIS FILE IS MANAGED BY PUPPET
---
sonatypeWork: /srv/clm-server
server:
  applicationConnectors:
  - type: http
    port: '8070'
  adminConnectors:
  - type: http
    port: '8071'
  requestLog:
    appenders:
    - type: file
      currentLogFilename: /var/log/clm-server/request.log
      archivedLogFilenamePattern: /var/log/clm-server/request-%d.log.gz
      archivedFileCount: '50'
logging:
  level: DEBUG
  loggers:
    com.sonatype.insight.scan: INFO
    eu.medsea.mimeutil.MimeUtil2: INFO
    org.apache.http: INFO
    org.apache.http.wire: ERROR
    org.eclipse.birt.report.engine.layout.pdf.font.FontConfigReader: WARN
    org.eclipse.jetty: INFO
    org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter: INFO
  appenders:
  - type: console
    threshold: INFO
    logFormat: '%d{''yyyy-MM-dd HH:mm:ss,SSSZ''} %level [%thread] %X{username} %logger
      - %msg%n'
  - type: file
    threshold: ALL
    logFormat: '%d{''yyyy-MM-dd HH:mm:ss,SSSZ''} %level [%thread] %X{username} %logger
      - %msg%n'
    currentLogFilename: /var/log/clm-server/clm-server.log
    archivedLogFilenamePattern: /var/log/clm-server/clm-server-%d.log.gz
    archivedFileCount: '50'
createSampleData: true

"
    ) }
  end

  # The only time we can verify if clm::config is getting a proper
  # merged config is from the root class, so we have to do a deep
  # inspection of the resultant config file
  context 'with modified clm_config it should produce a proper config file' do
    let(:params) {
      {
        'clm_config' => {
          'http'     => {
            'port'   => '8080',
          },
        }
      }
    }

    it { should contain_file('/etc/clm-config.yml').with_content(
      /http:\n  port: '8080'\n/
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
