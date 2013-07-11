require 'spec_helper'

describe 'the normalize_agents_arg function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  def expect_parse_error(args)
    lambda { scope.function_normalize_agents_arg(args) }.should(raise_error(Puppet::ParseError))
  end

  def expect(expected,arg)
    scope.function_normalize_agents_arg([arg]).should == expected
  end

  it 'should raise a ParseError if the number of args != 1' do
    expect_parse_error([])
    expect_parse_error(['a','b'])
  end

  it 'should raise a ParseError if arg is not Hash, String, Integer, Symbol, or Array' do
    expect_parse_error([Object.new])
  end

  it 'should return a hash for String, Integer, and Symbols' do
    expect({ 'a' => {}},'a')
    expect({ 'a' => {}},:a)
    expect({ '1' => {}},1)
  end

  it 'should return a hash for Array arguments' do
    expect({ 'a' => {}, 'b' => {}, '1' => {}},
           [1,:b,'a',:a])
  end

  it 'should return the unmodified argument for valid Hash' do
    hash = {'a' => {1 => 1}, :f => {2 => 2}}
    expect(hash,hash)
  end

  it 'should convert nil values to empty hashes for Hash argument' do
    expect({'a' => {},'b' => { 1 => 2 }},{'a' => nil,'b' => {1 => 2}})
    expect({'a' => {},'b' => { 1 => 2 }},{'a' => 'nil','b' => {1 => 2}})
    expect({'a' => {},'b' => { 1 => 2 }},{'a' => 'undef','b' => {1 => 2}})
  end

  it 'should raise an error if Hash argument has values that are not nil or a Hash' do
    expect_parse_error([{'a' => true}])
    expect_parse_error([{'a' => false}])
    expect_parse_error([{'a' => :f}])
  end
end
