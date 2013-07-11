require 'spec_helper'

describe 'bamboo_agent::service' do

  let(:pre_condition) { <<PUPPET
class bamboo_agent {
  $user_name = 'zenu'
}
include bamboo_agent
PUPPET
}

  let(:title) { 'foo' }
  let(:params) do
    {
      :home => '/tmp',
    }
  end

  it do
    attributes = {
      :ensure  => 'file',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0755',
    }

    should contain_file('/etc/init.d/bamboo-agentfoo').with(attributes).with_content(/zenu -c "\/tmp\/bin\/bamboo-agent.sh /)

    should contain_service('bamboo-agentfoo').with(
      {
         :ensure => 'running',
         :enable => true
      }
    )
  end
end
