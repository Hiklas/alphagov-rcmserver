require 'util/logger'
require 'rcmServer'
require 'test/unit'
require 'rack/test'

class RCMServerAppTest < Test::Unit::TestCase

  @@log = Util::LoggerLikeJava.new("RCMServerAppTest")

  include Rack::Test::Methods

  def app
    @@log.debug("Returning RCMServer class")
    RCM::RCMServer
  end

  def test_status
    @@log.debug("Testing status")
    get '/status'
    assert_equal '{ "status": "Testing status" }', last_response.body
  end

  def test_status_with_params
    @@log.debug("Testing status with parameters")
    get '/status', :name => 'Frank'
    assert_equal 'Testing status', last_response.body
  end

end

