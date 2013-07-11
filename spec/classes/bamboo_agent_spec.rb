require 'spec_helper'

describe 'bamboo_agent' do
  let(:facts) do { :r9util_download_curl_version => '2' } end

  context 'default parameters' do
    let(:params) do { :server_host => 'bamboo.com' } end

    it do
      should contain_r9util__system_user('bamboo')
      should contain_file('/usr/local/bamboo').with({
        :ensure => 'directory',
        :mode   => '0755',
        :owner  => 'bamboo',
        :group  => 'bamboo',
      })
      should contain_r9util__download('bamboo-agent-installer').with({
        :url => 'http://bamboo.com:8085/agentServer/agentInstaller',
        :path => '/usr/local/bamboo/bamboo-agent-installer.jar',
      })
      should contain_file('/usr/local/bamboo/bamboo-agent-installer.jar').with({
        :mode => '0644',
        :owner => 'bamboo',
        :group => 'bamboo',
      })
      should contain_bamboo_agent__agent('1')
    end
  end

  context 'single agent id' do
    let(:params) do 
      {
        :server_host    => 'bamboo.com',
        :agents         => 'foo',
      }
    end

    it do
      should contain_bamboo_agent__agent('foo')
    end
  end

  context 'multiple agents as array' do
    let(:params) do 
      {
        :server_host    => 'bamboo.com',
        :agents         => ['1','2'],
        :agent_defaults => {
          'manage_capabilities' => true,
        },
      }
    end

    it do
      should contain_bamboo_agent__agent('1').with_manage_capabilities(true)
      should contain_bamboo_agent__agent('2').with_manage_capabilities(true)
    end
  end

  context 'multiple agents as hash' do
    let(:params) do
      {
        :server_host    => 'bamboo.com',
        :agents         => {
          '1' => nil,
          '2' => {
            'manage_capabilities' => false,
          },
          '3' => {
            'private_tmp_dir' => true,
          },
          '4' => {},
        },
        :agent_defaults => {
          'manage_capabilities' => true,
          'capabilities' => { 'a' => '1' }
        }
      }
    end

    it do
      expected = {
        :manage_capabilities => true,
        :private_tmp_dir => false,
        :capabilities => { 'a' => '1' },
      }
      should contain_bamboo_agent__agent('1').with(expected)
      should contain_bamboo_agent__agent('2').with(expected.merge({:manage_capabilities => false}))
      should contain_bamboo_agent__agent('3').with(expected.merge({:private_tmp_dir => true}))
      should contain_bamboo_agent__agent('4').with(expected)
    end
  end


  context 'supply java classname' do
    let(:pre_condition) do <<PUPPET
class java {
}
PUPPET
    end

    let(:params) do {
      :server_host => 'bamboo.com',
      :java_classname => 'java',
    } end

    it do
      should include_class('java')
    end
  end

  context 'do not create user' do
    let(:params) do {
      :server_host => 'bamboo.com',
      :manage_user => false,
    } end

    it do
      should_not contain_r9util__system_user('bamboo')
    end
  end

  context 'special user options' do
    let(:params) do {
      :server_host  => 'bamboo.com',
      :user_name    => 'zenu',
      :user_options => {
         'group' => 'users',
      }
    } end

    it do
      should contain_r9util__system_user('zenu').with_group('users')
    end
  end
end
