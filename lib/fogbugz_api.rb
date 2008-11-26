module FogBugz
  
  def self.new_http_instance(url, options={}, token=nil)
    return FogBugzHttpApi.new(url, options, token)
  end

  # FogBugz super class
  class FogBugzApi
    
    attr :token, true
    attr :api_version, true
    attr :api_minversion, true
    attr :api_url, true
    
    def initialize(token)
      @token = token
    end
  
  end
end
