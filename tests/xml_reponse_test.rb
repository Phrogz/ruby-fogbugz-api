require 'rubygems'
require 'test/unit'
require 'shoulda'
require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz', 'xml_response')
include FogBugz

class XmlResponseHandlerTest < Test::Unit::TestCase
  
  def setup
    @data_dir = File.join(File.dirname(__FILE__), 'data')
    @response = XmlResponse.new(File.open(File.join(@data_dir, 'test.xml'), 'r') {|f| f.read})
    @simple_xml = '<text number="2" name="george"><paragraph>one</paragraph><test>two</test><test>three</test></text>'
  end
  
  context 'An XmlReponse instance' do
    should 'provide read access to the raw reponse string' do
      raw = File.open(File.join(@data_dir, 'test.xml'), 'r') {|f| f.read }
      assert_not_nil @response.raw
      assert_equal @response.raw, raw
    end
    
    should 'print the raw reponse when object is represented as a string' do
      assert_equal @response.raw, @response.to_s
    end
    
    should 'not allow modification of the raw reponse' do
      assert_raise NoMethodError do
        @response.raw = 'new response'
      end
      raw = File.open(File.join(@data_dir, 'test.xml'), 'r') {|f| f.read }
      resp = XmlResponse.new(raw)
      assert_not_same raw, resp.raw
    end
    
    should 'not permit malformed xml for raw input' do
      assert_raise BadResponseError do
        XmlResponse.new('Bad Xml')
      end
    end
    
    context 'with welformed raw input' do
      should 'store text node values in hash indexed by $' do
        @response = XmlResponse.new(@simple_xml)
        assert_equal = @response.to_hash['$'], 'test'
      end
      
      should 'store attributes in hash indexed by @name' do
        @response = XmlResponse.new(@simple_xml)
        assert_equal @response.to_hash['@number'], '2'
        assert_equal @response.to_hash['@name'], 'george'
      end
      
      should 'store nested elements in the hash indexed by the element name' do
        @response = XmlResponse.new(@simple_xml)
        assert_not_nil @response.to_hash['paragraph']
        assert_equal @response.to_hash['paragraph']['$'], 'one'
      end
      
      should 'store muliple nested elements in array indexed by element name' do
         assert_instance_of Array, @response.to_hash['filters']['filter']
         assert_equal @response.to_hash['filters']['filter'].size, 14
         @response = XmlResponse.new(@simple_xml)
         assert_instance_of Array, @response.to_hash['test']
         assert_equal @response.to_hash['test'].first['$'], 'two'
      end
    end
  end
end