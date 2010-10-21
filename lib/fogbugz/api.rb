module FogBugz
  class FogBugzError < StandardError; end
    
  module Api
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    def execute_cmd(cmd, builder=nil, options={})
      resp = execute_callback.call(cmd, builder, options)
      error_check(resp)
      return resp
    end
    
    def api_version
      version_callback.call(VERSION_URL)
    end
    
    def logon(email, password)
      resp = execute_cmd('logon', builder.email(email).password(password))
      self.token = resp.xpath('//token[1]').text
    end
    
    def logout
      execute_cmd('logout')
      self.token = nil
    end
    
    module ClassMethods 
      def version
        API_VERSION
      end
      
      def case_columns
        CASE_COLUMNS
      end
      
      def version_url
        VERSION_URL
      end
    end
    
    protected
    def version_check
      resp = api_version.to_hash
      self.api_version = resp['version']['$'].to_i
      self.api_minversion = resp['minversion']['$'].to_i
      self.api_url = "/%s" % resp['url']['$']
      raise FogBugzError, "API version mismatch" if (self.class.version < api_minversion)
    end
    
    private
    def error_check(resp)
      raise FogBugzError, resp.xpath('//error[1]').text if error?(resp)
    end
    
    def error?(resp)
      return !resp.xpath('//error[1]').empty?
    end
    
    private
    VERSION_URL = 'api.xml'
    
    API_VERSION = 6
  
    CASE_COLUMNS = %w(ixBug fOpen sTitle sLatestTextSummary ixBugEventLatestText
      ixProject sProject ixArea sArea ixGroup ixPersonAssignedTo sPersonAssignedTo
      sEmailAssignedTo ixPersonOpenedBy ixPersonResolvedBy ixPersonClosedBy
      ixPersonLastEditedBy ixStatus sStatus ixPriority sPriority ixFixFor sFixFor
      dtFixFor sVersion sComputer hrsOrigEst hrsCurrEst hrsElapsed c sCustomerEmail
      ixMailbox ixCategory sCategory dtOpened dtResolved dtClosed ixBugEventLatest
      dtLastUpdated fReplied fForwarded sTicket ixDiscussTopic dtDue sReleaseNotes
      ixBugEventLastView dtLastView ixRelatedBugs sScoutDescription sScoutMessage
      fScoutStopReporting fSubscribed events)
      
  end
end