require 'util/lumber'
require 'rcmServer'
require 'test/unit'
require 'rack/test'

class RCMServerAppMailTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailTest")

  include Rack::Test::Methods

  RCM_CONFIG_ENV = RCM::RCMServer::RCM_CONFIG_ENV
  RCM_TEST_CONFIG_FILE = 'test/conf/rcm-server.yaml'


  def app
    @@log.debug("Returning RCMServer class")
    ENV[RCM_CONFIG_ENV] = RCM_TEST_CONFIG_FILE
    RCM::RCMServer
  end


  def test_submit_with_empty
    #@@log.debug("Testing submit data with empty body")
    #post '/submitEvidence', '', 'Content Type' => 'application/json'
    #lastCode = last_response.status
    #assert(lastCode == 400, "We got the wrong return code: #{lastCode}")
  end

end

