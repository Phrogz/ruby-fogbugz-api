module FogBugz
  class BadResponseError < StandardError; end
    
  module XmlProcessor
    def to_hash
      @bager_hash ||= make_hash(XmlProcessor.make_node(@doc.root))
    end
    
    def xpath(expression)
      @doc.xpath(expression) do |n|
        yield n if block_given?
      end
    end
    
    protected
    def parse
      begin
        @doc = Nokogiri::XML.parse(raw_xml, nil, 'UTF-8', Nokogiri::XML::PARSE_NOBLANKS)
      rescue RuntimeError => e
        raise BadResponseError.new(e.message)
      end  
    end
    
    private
    def make_hash(xml_node)
      node = Hash.new
      xml_node.attributes.each {|k, v| node["@%s" % k] = v } unless xml_node.text?
      xml_node.children.each do |c|
        unless c.text?
          k, v = c.name, make_hash(c)
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
    
    class XmlNode  
      def name
        @node.name
      end
      
      def text?
        [XML_TEXT_NODE, XML_CDATA_SECTION_NODE].include?(@node.type)  
      end
      
      protected
      attr_reader :node
      def initialize(node)
        @node = node
      end
    end
    
    class TextNode < XmlNode 
      def text
        node.text
      end
      
      protected
      def initialize(node)
        super(node)
      end
    end
    
    class ElementNode < XmlNode  
      def children
        node.children.map {|c| XmlProcessor.make_node(c) }
      end
      
      def attributes
        node.attributes
      end
      
      protected
      def initialize(node)
        super(node)
      end
    end
    
    XML_ELEMENT_NODE = 1
    XML_TEXT_NODE = 3
    XML_CDATA_SECTION_NODE = 4
    
    @@node_types = {
      XML_ELEMENT_NODE => ElementNode,
      XML_TEXT_NODE => TextNode,
      XML_CDATA_SECTION_NODE => TextNode
    }

    def self.make_node(node)
      @@node_types[node.type].send(:new, node)
    end
    
  end
end