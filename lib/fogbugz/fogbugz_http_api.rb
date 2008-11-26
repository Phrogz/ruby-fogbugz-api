module FogBugz
  class FogBugzHttpApi < FogBugzApi
    include HttpTransport, Api, Api::Helpers
    
    attr_reader :url, :use_ssl, :port, :secure_port, :method
    
    def version_callback
      Proc.new {|u| response_handler.call(send_payload(u, builder))}
    end
    
    def execute_callback
      Proc.new do |c, b, o|
        b = builder unless b
        b.cmd(c)
        b.token(token) if token
        response_handler.call(send_payload(api_url, b))
      end
    end
    
    def response_handler
      Proc.new {|r| XmlResponse.new(r).to_hash }
    end
    
    def initialize(url, options={}, token=nil)
      super(token)
      @url = url
      @use_ssl = options.key?(:use_ssl) ? options[:use_ssl] : false
      @port = options.key?(:port) ? options[:port] : 80
      @secure_port = options.key?(:secure_port) ? options[:secure_port] : 443
      @method = options.key?(:method) ? options[:method] : :get
      version_check
    end
    
  end
end