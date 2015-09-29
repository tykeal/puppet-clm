require 'spec_helper'
describe 'clm::service', :type => :class do

  context 'with defaults for all parameters' do
    it { should contain_class('clm::service') }
  end
end

# vim: sw=2 ts=2 sts=2 et :
