require 'cgi'

module FogBugz
  class QueryBuilder
    def initialize
      @args = {}
    end
    
    def size
      @args.size
    end
    
    def clear
      @args.clear
    end
    
    def parameter?(param)
      @args.key?(param)
    end
    
    def build
      @args.map {|k, v| "%s=%s" % [k, prepare_value(v)]}.join('&')
    end
    
    def method_missing(name, *args)
      if args.size > 0
        @args[name] = args.size > 1 ? args.map{|i| i.to_a}.flatten : [args.shift]
      else
        return @args[name] if @args.key?(name)
        super
      end
    end
    
    private
    def prepare_value(v)
      v.map{|a| CGI.escape(a)}.join(',')
    end
  end
end