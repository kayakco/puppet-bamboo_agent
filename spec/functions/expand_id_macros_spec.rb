require 'spec_helper'

describe 'the expand_id_macros function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  def expect_parse_error(args)
    lambda { scope.function_expand_id_macros(args) }.should(raise_error(Puppet::ParseError))
  end

  def expect_expanded(expected,args)
    scope.function_expand_id_macros(args).should == expected
  end

  it 'should raise a ParseError if the number of args != 2' do
    expect_parse_error([])
    expect_parse_error(['a'])
    expect_parse_error(['a','b','c'])
  end

  it 'should raise a ParseError if first arg not hash' do
    expect_parse_error(['',''])
    expect_parse_error(['',{}])
    expect_parse_error([0,''])
  end

  it 'should expand macros in keys and values' do
    expect_expanded({ 'foo1' => '1' },[{'foo!ID!' => '!ID!'},1])
    input = {
      '!ID!' => 'z',
      'a!ID!' => 'b!ID!',
      'a' => 'b',
      'aID' => 'ID',
      'foo' => 'bar!ID!',
      'foo2' => '!ID',
      'q' => '1',
    }

    expected = {
      '1' => 'z',
      'a1' => 'b1',
      'a' => 'b',
      'aID' => 'ID',
      'foo' => 'bar1',
      'foo2' => '!ID',
      'q' => '1',
    }
    expect_expanded(expected,[input,1])
  end
end
