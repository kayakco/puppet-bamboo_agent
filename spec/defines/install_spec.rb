require 'spec_helper'

describe 'bamboo_agent::install' do
  let(:pre_condition) { <<PUPPET
class bamboo_agent {
  $user_name = 'zenu'
  $user_group = 'zenu'
  $java_command = 'j 2'
  $installer_jar = '/tmp/b. .jar'
  $server_url = 'http://b.com' 
}
include bamboo_agent
PUPPET
}

  let(:title) { "install-${id}" }
  let(:params) {{ :home => '/b1home', :id => '2' }}

  it do
    should contain_exec('install-agent-2').with({
      :creates => '/b1home/bin/bamboo-agent.sh',
      :user    => 'zenu',
      :group   => 'zenu',
      :command => '"j 2" -Dbamboo.home=/b1home  -jar "/tmp/b. .jar" http://b.com/agentServer/ install',
    })
  end
end
