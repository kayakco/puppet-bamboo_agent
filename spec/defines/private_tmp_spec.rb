require 'spec_helper'

describe 'bamboo_agent::private_tmp' do

  let :title do '/footmp' end

  let :pre_condition do <<PUPPET
class bamboo_agent {
  $user_name = 'zenu'
  $user_group = 'zenu'
}
include bamboo_agent
PUPPET
  end

  it do
    should contain_file('/footmp').with({
      :ensure => 'directory',
      :owner  => 'zenu',
      :group  => 'zenu',
      :mode   => '0755',
    })
    should contain_package('tmpwatch')
    should contain_cron('/footmp-tmp-cleanup').with({
      :command => '/usr/sbin/tmpwatch 10d /footmp',
      :minute  => 15,
    })
  end
end
