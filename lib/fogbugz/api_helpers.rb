module FogBugz
  module Api
    module Helpers
    
      def logon(email, password)
        resp = execute_cmd('logon', builder.email(email).password(password))
        self.token = resp['token']['$']
      end
      
      def logout
        execute_cmd('logout')
        self.token = nil
      end
      
      def filters
       []
      end
    
    end
  end
end