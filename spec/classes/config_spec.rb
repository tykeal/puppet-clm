require 'spec_helper'
describe 'clm::config', :type => :class do
  let (:params) {
    {
      'clm_config'     => {
        'test'         => {
          'sub_option' => 'sub_option test',
        },
        'test2'        => {
          'sub_option' => 'sub_option test2',
        },
        'test3'        => 'test3',
        'test4'        => [
          'array1',
          'array2',
        ],
      },
      'clm_group'      => 'foo',
      'clm_user'       => 'foo',
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

  context 'with basic params set' do
    it { should contain_file('/etc/clm-config.yml').with(
      'ensure' => 'file',
      'owner'  => 'foo',
      'group'  => 'foo',
      'mode'   => '0600',
      'content' => '# WARNING THIS FILE IS MANAGED BY PUPPET
---
test:
  sub_option: sub_option test
test2:
  sub_option: sub_option test2
test3: test3
test4:
- array1
- array2

',
    ) }
  end
end

# vim: sw=2 ts=2 sts=2 et :
