require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'cgi'
require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz-api')
include FogBugz

class QueryBuilderTest < Test::Unit::TestCase
  def setup
    super
    @builder = QueryBuilder.new
  end
  
  context 'A QueryBuilder instance' do
    should 'initially have no parameters' do
      assert_equal @builder.size, 0
    end
    
    should 'store parameter values in a list' do
      @builder.test1('test1')
      assert @builder.parameter?('test1')
      @builder.test2('test2', 'test3')
      assert @builder.parameter?('test2')
      assert_equal @builder.test1, ['test1']
      assert_equal @builder.test2, ['test2', 'test3']
    end
    
    should 'flatten parameter values given as a collection' do
      @builder.test1({:test2 => 'test2'}, 'test1', ['test3', 'test4'])
      assert_equal @builder.test1, ['test2', 'test2', 'test1', 'test3', 'test4']
    end
    
    should 'store parameters that are called as methods' do
      @builder.test1('test1')
      assert @builder.parameter?('test1')
      @builder.test2('test2')
      @builder.parameter?('test2')
      assert @builder.parameter?('test2')
    end
    
    context 'containing parameters' do
      should 'provide the size of the contained parameters' do
        @builder.test1('test1')
        @builder.test2('test2')
        assert_equal @builder.size, 2
      end
      
      should 'index parameters by string name and symbol name' do
        @builder.test1('test1')
        assert @builder.parameter?(:test1)
        assert @builder.parameter?('test1')
      end
      
      should 'update existing parameters with new values' do 
        @builder.test1('old value')
        @builder.test1('new value')
        assert_equal @builder.test1, ['new value']
      end
      
      should 'clear parameters' do
        @builder.test1('test1')
        @builder.test2('test2')
        @builder.clear
        assert_equal @builder.size, 0
      end
      
      context 'outputing a query string' do
        should 'produce a valid query string' do
          @builder.test1('value1 with space')
          assert_equal @builder.build, 'test1=' << CGI.escape('value1 with space')
          @builder.test2('value2')
          assert @builder.build.include?('test2=value')
          @builder.test3('value3')
          assert_equal @builder.build.count('&'), 2
        end
        
        should 'delimit multiple parameter values with a comma' do
          @builder.test1('value1', 'value2', 'value3')
          assert_equal @builder.build, 'test1=value1,value2,value3'
        end
      end

    end
  end
end
