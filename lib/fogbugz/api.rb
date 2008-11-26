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
    
    module ClassMethods
 
      def version
        API_VERSION
      end
      
      def case_columns
        CASE_COLUMNS
      end
      
      def error_codes
        ERROR_CODES
      end
      
      def version_url
        VERSION_URL
      end
    end
    
    protected
    def version_check
      resp = api_version
      self.api_version = resp['version']['$'].to_i
      self.api_minversion = resp['minversion']['$'].to_i
      self.api_url = "/%s" % resp['url']['$']
      raise FogBugzError, "API version mismatch" if (self.class.version < api_minversion)
    end
    
    private
    def error_check(resp)
      raise FogBugzError, resp['error']['$'] if error?(resp)
    end
    
    def error?(resp)
      return resp.key?('error')
    end
    
    private
    VERSION_URL = '/api.xml'
    
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
    
    ERROR_CODES = {"0"=>"FogBugz not initialized.  Database may be down or needs to be upgraded",
                   "1"=>"Log On problem - Incorrect Username or Password",
                   "2"=>"Log On problem - multiple matches for username",
                   "3"=>"You are not logged on.",
                   "4"=>"Argument is missing from query",
                   "5"=>"Edit problem - the case you are trying to edit could not be found",
                   "6"=>"Edit problem - the action you are trying to perform on this case is not permitted",
                   "7"=>"Time tracking problem - you can't add a time interval to this case because the case can't be found, is closed, has no estimate, or you don't have permission",
                   "8"=>"New case problem - you can't write to any project",
                   "9"=>"Case has changed since last view",
                   "10"=>"Search problem - an error occurred in search.",
                   "12"=>"Wiki creation problem",
                   "13"=>"Wiki permission problem",
                   "14"=>"Wiki load error",
                   "15"=>"Wiki template error",
                   "16"=>"Wiki commit error",
                   "17"=>"No such project",
                   "18"=>"No such user",
                   "19"=>"Area creation problem",
                   "20"=>"FixFor creation problem",
                   "21"=>"Project creation problem",
                   "22"=>"User creation problem"
                  }
  end
end