require 'cgi'

module FogBugz
  class QueryBuilder
    def initialize
      @params = Hash.new([])
    end
    
    def size
      @params.size
    end
    
    def clear
      @params.clear
    end
    
    def parameter?(param)
      @params.key?(param.to_sym)
    end
    
    def build
      @params.map {|k, v| "%s=%s" % [k, prepare_value(v)]}.join('&')
    end
    
    def method_missing(name, *args)
      if args.size > 0
        @params[name.to_sym] = args.size > 1 ? args.map{ |o| [*o] }.flatten.map{ |o| o.to_s } : [ args.shift ]
        return self
      else
        return @params[name] if parameter?(name)
        super
      end
    end
    
    private
    def prepare_value(v)
      v.map {|i| CGI.escape(i)}.join(',')
    end
  end
end