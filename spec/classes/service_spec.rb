require 'spec_helper'
describe 'clm::service', :type => :class do
  let (:params) {
    {
      'clm_group'     => 'foo',
      'clm_user'      => 'foo',
      'clm_user_home' => '/opt/foo',
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

  context 'with valid test params' do
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

[Install]
WantedBy=multi-user.target
',
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
