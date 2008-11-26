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
        execute_cmd('listFilters')['filters']['filter'].inject(Hash.new({})) do |resp, f|
          name = f['$']
          resp[name] = f.keys.inject({}) {|a, v| a[v.gsub('@','')] = f[v] if v =~ /^@.+/; a}
          resp[name].merge!({'name'=> name})
          resp
        end
      end
      
      def projects(fWrite=false, ixProject=nil)
        bld = builder do |b|
          b.fWrite(1.to_s) if fWrite
          b.ixProject(ixProject) if ixProject
        end
        execute_cmd('listProjects', bld)
      end
      
      private
      # TODO finish this function for compatibility with old version of api wrapper
      def list_process(items, idx)
        items.inject(Hash.new({})) do |resp, item|
          name = item[idx]['$']
          resp[name] = item.each {|k, v| }
        end
      end
    end
  end
end