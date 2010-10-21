require 'rubygems'
require "test/unit"
require 'shoulda'
require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz-api')
include FogBugz

class XmlTest < Test::Unit::TestCase
  def setup
    super
    @simple_xml = '<text number="2" name="george"><paragraph>one</paragraph><test>two</test><test>three</test></text>'
    @simple_root = Xml.parse(@simple_xml).root
  end
  
  context 'Xml parsing' do
    should 'not permit malformed xml content' do
      assert_raise XmlResponseError do
        Xml.parse('Bad Xml')
      end
    end
    
    should 'not permit nil for xml input' do
      assert_raise XmlResponseError do
        Xml.parse(nil)
      end
    end
    
    context 'of a well formed document' do
      should 'produce a XmlDocument' do
        doc = Xml.parse(@simple_xml)
        assert_kind_of Xml::XmlDocument, doc
      end
    end
  end
  
  context 'A XmlDocument instance' do
    should 'provide access to its root node' do
      doc = Xml.parse(@simple_xml)
      assert_respond_to doc, :root
      assert_kind_of Xml::XmlNode, doc.root
    end
  end
  
  context 'A XmlNode instance' do
    should 'provide read only access to its name property' do
      doc = Xml.parse(@simple_xml)
      assert_equal 'text', doc.root.name
      assert_raise NoMethodError do
        doc.root.name = 'new name'
      end
    end
    
    should 'provide a list of child nodes' do
      assert_equal 3, @simple_root.children.size
      assert_equal 'paragraph', @simple_root.children.first.name
    end
    
    should 'provide access to its inner text' do
      assert_equal 'onetwothree', @simple_root.text
      assert_equal 'one', @simple_root.children.first.text
    end
    
    should 'provide access to its attributes' do
      assert_equal 'george', @simple_root.attributes['name']
      assert_equal '2', @simple_root.attributes['number']
      assert @simple_root.children.first.children.first.attributes.empty?
    end
    
    should 'indicate it is text if it is a text node' do  
      assert_equal 'one', @simple_root.children.first.children.first.text
      assert @simple_root.children.first.children.first.text?
    end
    
    should 'support searching child nodes with xpath expressions' do
      assert_equal 'two', @simple_root.xpath('//test[1]').text
      assert_equal 'one', @simple_root.xpath('/text/paragraph').text
      assert_equal 2, @simple_root.xpath('//test').size
    end
    
    should 'not permit bad xpath expressions' do
      assert_raise XPathExpressionError do
        @simple_root.xpath('\\\\')
      end
    end
    
    should 'provide a hash that conforms to the badgerfish convention' do
      hash = @simple_root.to_hash
      assert_equal hash['@number'], '2'
      assert_equal hash['@name'], 'george'
      assert_not_nil hash['paragraph']
      assert_equal hash['paragraph']['$'], 'one'
      assert_instance_of Array, hash['test']
      assert_equal hash['test'].first['$'], 'two'
    end
  end
  
  context 'A NodeSet instance' do
    should 'indicate if it is empty' do
      # Nokogiri nodesets must be associated with a document
      # I have no idea what document one might be supposed to create for this
      # ns = Xml::NodeSet.new(nil)
      # assert ns.empty?

      assert @simple_root.xpath('//notthere').empty?
    end
    
    should 'provide read access to the first member of the set' do
      tests = @simple_root.xpath('//test')
      assert_equal 'two', tests.first.text
    end
    
    should 'indicate the size of the set' do
      assert_equal 2, @simple_root.xpath('//test').size
    end
    
    should 'iterate over each member of the set' do
      @simple_root.xpath('//test').each do |n|
        assert_instance_of Xml::XmlNode, n
      end
    end
    
  end
end