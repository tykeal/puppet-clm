require 'spec_helper'
describe 'clm::install', :type => :class do
  let (:params) {
    {
      'clm_config'       => {
        # this is the only parameter we actually care about in the config hash
        # in clm::install
        'sonatypeWork'   => '/foo/bar',
      },
      'clm_group'        => 'foo',
      'clm_user'         => 'foo',
      'clm_user_home'    => '/opt/foo',
      'download_site'    => 'http://downloadtest.com',
      'revision'         => '01',
      'version'          => '1.1.1',
      'work_dir_manage'  => true,
      'work_dir_recurse' => true,
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

  context 'with clm::params defaults for all parameters' do
    it { should contain_class('clm::install') }

    it { should contain_wget__fetch('sonatype-clm-server-1.1.1-01-bundle.tar.gz').with(
      'source'      => 'http://downloadtest.com/sonatype-clm-server-1.1.1-01-bundle.tar.gz',
      'destination' => '/opt/foo/sonatype-clm-server-1.1.1-01-bundle.tar.gz',
      'before'      => 'Exec[clm-untar]',
    ) }

    it { should contain_file('/opt/foo/sonatype-clm-server-1.1.1-01').with(
      'ensure'  => 'directory',
      'owner'   => 'foo',
      'group'   => 'foo',
      'recurse' => true,
      'before'  => 'Exec[clm-untar]',
    ) }

    it { should contain_exec('clm-untar').with(
      'command' => 'tar zxf /opt/foo/sonatype-clm-server-1.1.1-01-bundle.tar.gz',
      'cwd'     => '/opt/foo/sonatype-clm-server-1.1.1-01',
      'creates' => '/opt/foo/sonatype-clm-server-1.1.1-01/sonatype-clm-server-1.1.1-01.jar',
      'path'    => [ '/bin', '/usr/bin' ],
    ) }

    it { should contain_file('/opt/foo/clm-server').with(
      'ensure'  => 'link',
      'target'  => '/opt/foo/sonatype-clm-server-1.1.1-01',
      'require' => 'Exec[clm-untar]',
    ) }

    it 'should fail if clm_config.sonatypeWork does not exist' do
      params.merge!({'clm_config' => {}})
  
      expect {
        should compile
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
        /A sonatypeWork /)
    end

    it { should contain_file('/foo/bar').with(
      'ensure'  => 'directory',
      'owner'   => 'foo',
      'group'   => 'foo',
      'recurse' => true,
      'require' => 'Exec[clm-untar]',
    ) }

    it 'should not contain file /foo/bar if work_dir_manage is false' do
      params.merge!({'work_dir_manage' => false})

      should_not contain_file('/foo/bar')
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :