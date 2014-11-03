require 'spec_helper'

describe 'bamboo_agent' do
  
  let(:facts) do
    {
      # For puppetlabs/java facts
      :osfamily => 'Debian',
      :lsbdistcodename => 'natty',
    }
  end

  context 'default parameters' do
    let(:params) do { :server_url => 'https://bamboo.com:8000/bamboo' } end

    it do
      should contain_r9util__system_user('bamboo')
      should contain_file('/usr/local/bamboo').with({
        :ensure => 'directory',
        :mode   => '0755',
        :owner  => 'bamboo',
        :group  => 'bamboo',
      })
      should contain_r9util__download('bamboo-agent-installer').with({
        :url => 'https://bamboo.com:8000/bamboo/agentServer/agentInstaller',
        :path => '/usr/local/bamboo/bamboo-agent-installer.jar',
      })
      should contain_file('/usr/local/bamboo/bamboo-agent-installer.jar').with({
        :mode => '0644',
        :owner => 'bamboo',
        :group => 'bamboo',
      })
      should contain_bamboo_agent__agent('1')
      should contain_class('java')
      should_not contain_notify('bamboo-module-deprecation-warning')
    end
  end

  context 'single agent id' do
    let(:params) do 
      {
        :server    => 'bamboo.com',
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
        :server_url => 'bamboo.com',
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
        :server_url     => 'bamboo.com',
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
class myjava {
}
PUPPET
    end

    let(:params) do {
      :server_url => 'bamboo.com',
      :java_classname => 'myjava',
    } end

    it do
      should contain_class('myjava')
      should_not contain_class('java')
    end
  end

  context 'set java_classname to undefined' do
    let(:params) do {
      :server_url => 'bamboo.com',
      :java_classname => 'UNDEFINED',
    } end

    it do
      should_not contain_class('java')
    end
  end

  context 'do not create user (boolean parameter)' do
    let(:params) do {
      :server_url => 'bamboo.com',
      :manage_user => false,
    } end

    it do
      should_not contain_r9util__system_user('bamboo')
    end
  end

  context 'do not create user (string parameter)' do
    let(:params) do {
      :server_url => 'b',
      :manage_user => 'false',
    } end

    it do
      should_not contain_r9util__system_user('bamboo')
    end
  end

  context 'special user options' do
    let(:params) do {
      :server_url   => 'bamboo.com',
      :user_name    => 'zenu',
      :user_options => {
         'group' => 'users',
      },
      :manage_user => 'true',
    } end

    it do
      should contain_r9util__system_user('zenu').with_group('users')
    end
  end

  context 'with deprecated server options' do
    let (:params) do {
      :server          => 'my.bamboo.server',
      :server_port     => '9000',
      :server_protocol => 'idk',
    } end

    it 'should log a warning but construct expected url' do
      should contain_r9util__download('bamboo-agent-installer').with({
        :url => 'idk://my.bamboo.server:9000/agentServer/agentInstaller',
      })
      should contain_notify('bamboo-module-deprecation-warning').with_message(/\$server_url/)
    end
  end

  context 'with deprecated server options (default port & protocol)' do
    let (:params) do {
      :server => 'my.bamboo.server',
    } end

    it 'should log a warning but construct expected url' do
      should contain_r9util__download('bamboo-agent-installer').with({
        :url => 'http://my.bamboo.server:8085/agentServer/agentInstaller',
      })
     should contain_notify('bamboo-module-deprecation-warning').with_message(/\$server_url/)
    end
  end

  context 'without server or server_url options' do
    let (:params) do {} end

    it 'should fail' do
      expect {
        should contain_bamboo_agent__agent('1')
      }.to raise_error(Puppet::Error, /\$server_url is required/)
    end
  end
end
