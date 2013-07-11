require 'spec_helper'

describe 'bamboo_agent::capabilities' do
  before :each do
    home = '/foo'
    test_capabilities = {
      'a' => 1,
      'b' => '2',
      ' a df ' => "  tra\nla la",
      'id' => '--!ID!--',
    }
    @test_params = {
      :home         => home,
      :capabilities => test_capabilities,
      :expand_id_macros => true,
    }
    @file  = "#{home}/bin/bamboo-capabilities.properties"
    @attributes = Proc.new do |idvalue|
      {
        :ensure  => 'file',
        :owner   => 'bamboo',
        :group   => 'bamboo',
        :mode    => '0644',
        :content => <<CONTENT
# This file is managed by Puppet! Any manual changes will probably be
# overridden.
#
# (template: bamboo_agent/templates/bamboo-capabilities.properties.erb)
#
 a df =  tra
la la
a=1
b=2
id=#{ idvalue }
CONTENT
      }
    end
  end

  context 'Expand macros' do
    let :title do '23' end
    let :params do @test_params end

    it do
      should contain_file(@file).with(@attributes.call('--23--'))
    end
  end

  context 'Expand macros with id as separate param' do
    let :title do 'nonsense' end
    let :params do @test_params.merge({ :id => '25' }) end

    it do
      should contain_file(@file).with(@attributes.call('--25--'))
    end
  end

  context 'Do not expand macros' do
    let :title do '23' end
    let :params do @test_params.merge({ :expand_id_macros => false }) end

    it do
      should contain_file(@file).with(@attributes.call('--!ID!--'))
    end
  end

end
