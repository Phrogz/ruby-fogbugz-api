module FogBugz
  class XmlResponseError < StandardError; end
  class XPathExpressionError < StandardError; end  

  module Xml

    def self.parse(xml)
      raise XmlResponseError.new, 'xml input is nil' if xml.nil?
      begin
        XmlDocument.new(Nokogiri::XML.parse(xml, nil, 'UTF-8', Nokogiri::XML::ParseOptions::NOBLANKS))
      rescue StandardError => e
        raise XmlResponseError.new, e.message
      end
    end
    
    class XmlDocument
      def initialize(doc)
        @doc = doc
      end
      
      def root
        Xml.make_node(@doc.root)
      end
    end
    
    class NodeSet
      include Enumerable
      def initialize(node_set)
        @node_set = node_set || Nokogiri::XML::NodeSet.new
      end
      
      def empty?
        @node_set.empty?
      end
      
      def first
        @node_set.first
      end
      
      def text
        @node_set.text
      end
      
      def size
        @node_set.size
      end
      
      def each
        @node_set.each {|n| yield Xml.make_node(n)}
      end
      
      protected
      attr_reader :node_set
    end
    
    class XmlNode
      def name
        @node.name
      end
      
      def children
        @children ||= @node.children.map {|c| Xml.make_node(c) }
      end
      
      def xpath(expression)
        begin
          NodeSet.new(@node.xpath(expression))
        rescue StandardError => e
          raise XPathExpressionError.new, e.message
        end
      end
      
      def text
        @node.inner_text
      end
      
      def attributes
        Hash[ *@node.attributes.map{ |name,attr| [ name, attr.value] }.flatten ]
      end
      
      def text?
        [XML_TEXT_NODE, XML_CDATA_SECTION_NODE].include?(@node.type)  
      end
      
      def to_hash
        Xml.make_badger_hash(self)
      end
      
      protected
      attr_reader :node
      def initialize(node)
        @node = node
      end
    end
    
    private
    XML_ELEMENT_NODE = 1
    XML_TEXT_NODE = 3
    XML_CDATA_SECTION_NODE = 4
    
    def self.make_node(node)
      XmlNode.new(node)
    end
    
    def self.make_badger_hash(xml_node)
      node = Hash.new
      xml_node.attributes.each {|name, value| node["@#{name}"] = value } unless xml_node.text?
      xml_node.children.each do |c|
        unless c.text?
          k, v = c.name, make_badger_hash(c)
        else
          k, v = '$', c.text.strip
        end
        case node[k]
          when Array
            node[k] << v
          when nil
            node[k] = v
          else
            node[k] = [node[k].dup, v]
        end
      end
      return node
    end
    
  end
end