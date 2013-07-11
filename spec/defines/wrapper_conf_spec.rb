require 'spec_helper'

describe 'bamboo_agent::wrapper_conf' do
  let(:pre_condition) { <<PUPPET
class bamboo_agent {
  $user_name = 'z'
  $user_group = 'z'
}
include bamboo_agent
PUPPET
  }

  let(:title) { 'foo' }
  let(:params) do
    {
      :home => '/u',
      :properties => { 'a' => '1' }
    }
  end

  it do
    should contain_file('/u/conf/wrapper.conf').with({
      :owner => 'z',
      :group => 'z',
    })
    should contain_r9util__java_properties('/u/conf/wrapper.conf').with_properties({ 'a' => '1' })
  end
end
