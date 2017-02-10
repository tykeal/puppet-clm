require 'spec_helper'
describe 'clm::params', :type => :class do
  let (:facts) {
    {
      'kernel'                 => 'Linux',
      'osfamily'               => 'RedHat',
      'operatingsystem'        => 'Fedora',
      'operatingsystemrelease' => '14',
    }
  }

  context 'with defaults for all parameters' do
    it { should contain_class('clm::params') }
  end
end

# vim: sw=2 ts=2 sts=2 et :
