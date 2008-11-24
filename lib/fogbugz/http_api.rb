require 'query_builder'
require 'http_transport'

module FogBugz
  class HttpApi
    
    def self.new_instance(url, options={})
      self.send(:include, options.key?(:transport) ? options.delete(:transport) : HttpTransport)
      return HttpApi.new(url, options)
    end
    
    def execute(uri, cmd, params={})
      bldr = builder do |b|
        b.cmd(cmd.to_s)
        params.each {|k, v| b.send(k.to_sym, v)}
      end
      XmlResponse.new(send_payload(uri, bldr)).to_hash
    end
    
    private 
    def initialize(url, options)
      self.url = url
      self.use_ssl = options.key?(:use_ssl) ? options[:use_ssl] : false
      self.port = options.key?(:port) ? options[:port] : 80
      self.secure_port = options.key?(:secure_port) ? options[:secure_port] : 443
    end
    
    def builder
      b = QueryBuilder.new
      yield b if block_given?
      return b
    end
    
  end
end