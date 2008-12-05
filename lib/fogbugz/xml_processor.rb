module FogBugz
  class BadResponseError < StandardError; end
  class XPathExpressionError < StandardError; end
    
  module XmlProcessor
    def to_hash
      @bager_hash ||= XmlProcessor.make_node(@doc.root).to_hash
    end
    
    def xpath(expression)
      XmlProcessor.make_node(@doc.root).xpath(expression)
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
    def self.make_hash(xml_node)
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
    
    class NodeSet
      include Enumerable, Comparable
      def initialize(node_set)
        @node_set = node_set
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
        @node_set.each {|n| yield XmlProcessor.make_node(n)}
      end
      
      def <=>(other)
        return -1 unless other.respond_to?(:node_set)
        node_set <=> other.node_set
      end
      
      private
      attr_reader :node_set
    end
    
    class XmlNode
      def name
        @node.name
      end
      
      def xpath(expression)
        begin
          NodeSet.new(@node.xpath(expression))
        rescue RuntimeError => e
          raise XPathExpressionError.new, e.message
        end
      end
      
      def text
        @node.inner_text
      end
      
      def text?
        [XML_TEXT_NODE, XML_CDATA_SECTION_NODE].include?(@node.type)  
      end
      
      def to_hash
        XmlProcessor.make_hash(self)
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