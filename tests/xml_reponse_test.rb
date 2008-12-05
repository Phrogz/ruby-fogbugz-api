require 'rubygems'
require 'test/unit'
require 'shoulda'
require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz', 'xml_processor')
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
      assert_not_nil @response.raw_xml
      assert_equal @response.raw_xml, raw
    end
    
    should 'print the raw reponse when object is represented as a string' do
      assert_equal @response.raw_xml, @response.to_s
    end
    
    should 'not allow modification of the raw reponse' do
      assert_raise NoMethodError do
        @response.raw_xml = 'new response'
      end
      raw = File.open(File.join(@data_dir, 'test.xml'), 'r') {|f| f.read }
      resp = XmlResponse.new(raw)
      assert_not_same raw, resp.raw_xml
    end
    
    should 'not permit malformed xml for raw input' do
      assert_raise BadResponseError do
        XmlResponse.new('Bad Xml')
      end
    end
    
    context 'with welformed raw input' do
      should 'store text node values in hash indexed by $' do
        @response = XmlResponse.new('<test>test</test>')
        assert_equal 'test', @response.to_hash['$']
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
    
      should 'provide support of xpath expressions to in order to search document' do
        assert_equal 14, @response.xpath('//filter').size, 14
        assert_equal 'Inbox', @response.xpath('//filter[@sFilter="inbox"]').text
      end
    end
  end
end