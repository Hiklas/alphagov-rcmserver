require 'util/lumber'
require 'rcmServer'
require 'test/unit'
require 'rack/test'

class RCMServerAppMailTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailTest")

  include Rack::Test::Methods


  def app
    @@log.debug("Returning RCMServer class")
    RCM::RCMServer
  end


  def test_submit_with_empty
    #@@log.debug("Testing submit data with empty body")
    #post '/submitEvidence', '', 'Content Type' => 'application/json'
    #lastCode = last_response.status
    #assert(lastCode == 400, "We got the wrong return code: #{lastCode}")
  end

end

