require File.join(File.dirname(__FILE__), '..', 'lib', 'fogbugz', 'xml_response_handler')
include FogBugz

describe XmlResponseHandler do
  before(:each) do
    @handler = XmlReponseHandler.new
  end
  it 'should accept a raw xml input string as input' do
    
  end
end