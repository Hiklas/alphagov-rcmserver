require 'util/lumber'
require 'rcmServer'
require 'test/unit'
require 'rack/test'
require 'mail'

class RCMServerAppMailTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailTest")

  include Rack::Test::Methods

  SIMPLE_JSON_TO_EMAIL = '{ "name" : "Terry Pratchett", "status" : "Return to Sender" }'

  def app
    @@log.debug("Returning RCMServer class")
    RCM::RCMServer
  end


  def test_submit_with_simple_json
    @@log.debug("Testing submit data with simple JSON")
    post '/submitEvidence', SIMPLE_JSON_TO_EMAIL, 'Content Type' => 'application/json'
    lastCode = last_response.status

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    # Must do this otherwise it leaves deliveries in the queue and this breaks subsequent tests
    deliveries.clear
  end


  def test_submit_with_simple_json_check_contents
    @@log.debug("Testing submit data with simple JSON, checking contents")
    post '/submitEvidence', SIMPLE_JSON_TO_EMAIL, 'Content Type' => 'application/json'
    lastCode = last_response.status

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first


    # Must do this otherwise it leaves deliveries in the queue and this breaks subsequent tests
    deliveries.clear
  end

end

