require 'spec_helper'
describe 'clm::service', :type => :class do
  let (:facts) {
    {
      'osfamily'               => 'RedHat',
      'operatingsystem'        => 'Fedora',
      'operatingsystemrelease' => '14',
    }
  }

  let (:params) {
    {
      'clm_group'            => 'bar',
      'clm_user'             => 'foo',
      'clm_user_home'        => '/opt/foo',
      'clm_config_file'      => '/etc/clm-config.yml',
      'clm_environment_file' => '/etc/sysconfig/clm-server',
    }
  }

  # we do not have default values so the class should fail compile
  context 'with defaults for all parameters' do
    let (:params) {{}}

    it do
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
        /Must pass /)
    end
  end

  context 'with valid test params on RedHat' do
    it { should contain_class('clm::service') }

    it { should contain_file('clm-server-init').with(
      'ensure'  => 'file',
      'path'    => '/usr/lib/systemd/system/clm-server.service',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'content' => '# WARNING THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Sonatype CLM Server
After=network.target

[Service]
EnvironmentFile=/etc/sysconfig/clm-server
ExecStart=/usr/bin/java $JAVA_OPTIONS -jar $CLM_JAR server /etc/clm-config.yml
User=foo
Group=bar

[Install]
WantedBy=multi-user.target
',
      'notify' => 'Service[clm-server]',
    ) }

    it { should contain_service('clm-server').with(
      'ensure'  => 'running',
      'enable'  => true,
      'require' => 'File[clm-server-init]',
    ) }
  end

  context 'with valid test params on Debian' do
    let (:facts) {
      {
        'kernel'                 => 'Linux',
        'osfamily'               => 'Debian',
      }
    }
  
    it { should contain_class('clm::service') }

    it { should contain_file('clm-server-init').with(
      'ensure'  => 'file',
      'path'    => '/etc/systemd/system/clm-server.service',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'content' => '# WARNING THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Sonatype CLM Server
After=network.target

[Service]
EnvironmentFile=/etc/sysconfig/clm-server
ExecStart=/usr/bin/java $JAVA_OPTIONS -jar $CLM_JAR server /etc/clm-config.yml
User=foo
Group=bar

[Install]
WantedBy=multi-user.target
',
      'notify' => 'Service[clm-server]',
    ) }

    it { should contain_service('clm-server').with(
      'ensure'  => 'running',
      'enable'  => true,
      'require' => 'File[clm-server-init]',
    ) }
  end

  context 'with a SysV OS' do
    let(:facts) {
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.6',
      }
    }

    it { should_not compile }
  end
end

# vim: sw=2 ts=2 sts=2 et :
