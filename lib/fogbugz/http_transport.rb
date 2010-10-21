module FogBugz
  module HttpTransport
    
    def connected?
      !@conn.nil?
    end
    
    def builder
      b = QueryBuilder.new
      yield b if block_given?
      return b
    end
    
    protected
    def send_payload(uri, q_builder)
      connect unless connected?
      q_builder = builder unless q_builder
      @conn.send(method, [uri, q_builder.build].join ).body
    end
    
    private
    def connect
      @conn = Net::HTTP.new(url, use_ssl ? secure_port : port)
    end
    
  end
end
