require 'nokogiri'
module FogBugz
  
  class XmlResponse
    include FogBugz::XmlProcessor
    attr_reader :raw_xml
  
    def initialize(raw = '')
      @raw_xml = raw.dup
      parse
    end
    
    alias :to_s :raw_xml
  end
end