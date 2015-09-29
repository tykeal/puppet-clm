require 'spec_helper'
describe 'clm::config', :type => :class do

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
end

# vim: sw=2 ts=2 sts=2 et :
