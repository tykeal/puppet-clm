require 'spec_helper'
describe 'clm', :type => :class do

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
      /sonatypeWork: ["']?\/srv\/clm-server["']?\nhttp:\n  port: '8080'\n/
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
