require 'net/http'
module FogBugz
  module HttpTransport
    attr_writer :url, :use_ssl, :secure_port, :port
    
    def connected?
      !@conn.nil?
    end
    
    protected
    def send_payload(uri, q_builder, options={})
      connect unless connected?
      @conn.send(options.key?(:method) ? options[:method].to_sym : :get, 
        [uri, q_builder.build]).body
    end
    
    private
    def connect
      @conn = Net::HTTP.new(@url, @use_ssl ? @secure_port : @port)
    end
    
  end
end