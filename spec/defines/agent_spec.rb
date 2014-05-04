require 'spec_helper'

describe 'bamboo_agent::agent' do
  let (:pre_condition) { <<PUPPET
class bamboo_agent {
  $user_name = 'zenu'
  $user_group = 'users'
  $install_dir = '/b'
  $default_capabilities = { 'a' => 'foo' }
}
include bamboo_agent
PUPPET
  }
  context 'invalid agent id' do
    let :title do 'ab&c' end
    it 'should fail' do
      expect {
        should contain_bamboo_agent__install('install-agent-ab&c')
      }.to raise_error(Puppet::Error,/ab&c is not a valid agent id/)
    end
  end

  context 'with default parameters' do
    let (:title) do '1' end

    it do
      should contain_file('/b/agent1-home').with({
        :ensure => 'directory',
        :owner  => 'zenu',
        :group  => 'users',
        :mode   => '0755',
      })

      should contain_bamboo_agent__install('install-agent-1').with({
        :id => '1',
        :home => '/b/agent1-home',
      })
      should contain_bamboo_agent__service('1').with_home('/b/agent1-home')
      should contain_bamboo_agent__wrapper_conf('1').with({
        :home => '/b/agent1-home',
        :properties => {},
      })

      should_not contain_bamboo_agent__capabilities
      should_not contain_bamboo_agent__private_tmp
    end
  end

  context 'with wrapper properties' do
    let(:title) do '1' end
    let(:params) do { :wrapper_conf_properties => { 'a' => '1' }} end

    it do
      should contain_bamboo_agent__wrapper_conf('1').with({
        :home => '/b/agent1-home',
        :properties => { 'a' => '1'},
      })
    end
  end

  context 'manage capabilities with defaults' do
    let(:title) do '1' end
    let(:params) do { :manage_capabilities => true } end
    let(:facts) do { :hostname => 'foo' } end

    it do
      should contain_bamboo_agent__capabilities('1').with({
        :home => '/b/agent1-home',
        :expand_id_macros => true,
        :capabilities => { 'a' => 'foo' }
      })
    end
  end

  context 'manage capabilities with overrides' do
    let(:title) do '1' end
    let(:params) do {
      :manage_capabilities => true, 
      :capabilities => { 'a' => '1' },
      :expand_id_macros => false
    }
    end

    it do
    should contain_bamboo_agent__capabilities('1').with({
      :home => '/b/agent1-home',
      :expand_id_macros => false,
      :capabilities => {'a' => '1'},
    })
    end
  end

  context 'private tmp dir' do
    let :title do '1' end
    let :params do {
      :private_tmp_dir => true,
    }
    end

    it do
      should contain_bamboo_agent__private_tmp('/b/agent1-home/.agent_tmp')

      should contain_bamboo_agent__wrapper_conf('1').with({
        # These cannot be tested until Rspec Puppet is updated to compare
        # hashes properly.
        #:properties => {
        #  'set.TMP' => '/b/agent1-home/.agent_tmp',
        #  'wrapper.java.additional.3' => '-Djava.io.tmpdir=/b/agent1-home/.agent_tmp',
        #}
      })
    end
  end

  context 'with refresh_service' do
    let :title do '1' end
    let :params do {
      :manage_capabilities => true,
      :refresh_service => true,
    }
    end

    it do
      should contain_bamboo_agent__wrapper_conf('1').that_notifies('Bamboo_Agent::Service[1]')
      should contain_bamboo_agent__capabilities('1').that_notifies('Bamboo_Agent::Service[1]')
    end
  end
end
