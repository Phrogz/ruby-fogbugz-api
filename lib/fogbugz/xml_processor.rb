module FogBugz
    
  module XmlProcessor
    def to_hash
      @hash ||= @doc.root.to_hash
    end
    
    def xpath(expression)
      @doc.root.xpath(expression)
    end
    
    protected
    def parse
      @doc = FogBugz::Xml.parse(raw_xml)
    end
    
  end
end