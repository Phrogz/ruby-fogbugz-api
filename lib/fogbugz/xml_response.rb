require 'rubygems'
require 'nokogiri'

module FogBugz
  class BadResponseError < StandardError; end
  
  class XmlResponse
    attr_reader :raw
    
    XML_ELEMENT_NODE = 1
    XML_TEXT_NODE = 3
    XML_CDATA_SECTION_NODE = 4

    def initialize(raw = '')
      self.raw = raw
    end
    
    def to_hash
      @badger_hash ||= {}
    end
    
    alias :to_s :raw
    
    private
    def raw=(doc)
      @raw = doc.dup
      begin
        doc = Nokogiri::XML.parse(@raw, nil, 'UTF-8', Nokogiri::XML::PARSE_NOBLANKS)
        @badger_hash = make_hash(doc.root)
      rescue RuntimeError => e
        raise BadResponseError.new(e.message)
      end
    end
    
    def make_hash(xml_node)
      node = Hash.new
      xml_node.attributes.each {|k, v| node["@%s" % k] = v }
      xml_node.children.each do |c|
        unless text_node?(c)
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
    
    def text_node?(node)
      [XML_TEXT_NODE, XML_CDATA_SECTION_NODE].include?(node.type)
    end
  end
end