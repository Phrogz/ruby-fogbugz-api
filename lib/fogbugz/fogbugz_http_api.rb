module FogBugz
  class FogBugzHttpApi < FogBugzApi
    include HttpTransport, Api, Api::Helpers::Legacy
    
    attr_reader :url, :use_ssl, :port, :secure_port, :method
    
    def version_callback
      Proc.new {|url|
        response_handler.call(send_payload(File.join(@root,url), builder))
      }
    end
    
    def execute_callback
      Proc.new do |c, b, o|
        b ||= builder
        b.cmd(c)
        b.token(token) if token
        response_handler.call(send_payload(File.join(@root,api_url), b))
      end
    end
    
    def response_handler
      Proc.new {|r| XmlResponse.new(r) }
    end
    
    def initialize(url, options={}, token=nil)
      super(token)
      defaults = {
        :root        => '/',
        :use_ssl     => false,
        :port        => 80,
        :secure_port => 443,
        :method      => :get
      }
      @url = url
      @root, @use_ssl, @port, @secure_port, @method = defaults.merge(options).values_at( :root, :use_ssl, :port, :secure_port, :method )
      version_check
    end
    
  end
end