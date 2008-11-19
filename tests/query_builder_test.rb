require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz', 'query_builder')
include FogBugz

describe QueryBuilder do
  before(:each) do
    @builder = QueryBuilder.new
  end
  
  it 'should intitially have no parameters' do
    @builder.size.should equal(0)
  end
  
  it 'should provide the size of the contained parameters' do
    @builder.parameter1('test1')
    @builder.size.should equal(1)
    @builder.parameter2('test2')
    @builder.size.should equal(2)
  end
  
  it 'should accept and store parameters and their values' do
    @builder.parameter1('parameter1_value')
    @builder.should have_parameter('parameter1')
    @builder.parameter2('parameter2_value')
    @builder.should have_parameter('parameter2')
  end
  
  it 'should store multiple values for a parameter' do 
    @builder.parameter1('test1', 'test2')
    @builder.parameter1.should be_eql(['test1', 'test2'])
  end
  
  it 'should flatten array values for a parmeter' do
    @builder.parameter1(['test1', 'test2'], 'test3')
    @builder.parameter1.should be_eql(['test1', 'test2', 'test3'])
    @builder.parameter2({:parameter => 'parameter1'}, ['test', 'test1'])
    @builder.parameter2.should be_eql([:parameter, 'parameter1','test', 'test1'])
  end
  
  it 'should update parameters with new values' do
    @builder.parameter1('old value')
    @builder.parameter1('new_value')
    @builder.parameter1.should be_eql(['new_value'])
  end
  
  it 'should clear parameters' do
    @builder.parameter1('test')
    @builder.clear
    @builder.size.should equal(0)
  end
  
  it 'should build an http query string from the parameters' do
    @builder.parameter1('test1')
    @builder.build.should be_eql('parameter1=test1')
    @builder.parameter2('test2')
    @builder.build.should be_include('parameter2=test2')
    @builder.build.should be_include('parameter1=test1')
    @builder.parameter3('test3', 'test4')
    @builder.build.should be_include('parameter3=test3,test4')
  end
  
end