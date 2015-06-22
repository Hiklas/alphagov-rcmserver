require 'util/lumber'
require 'rcmServer'
require 'test/unit'
require 'rack/test'
require 'mail'
require 'test_utils'


class RCMServerAppMailTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailTest")

  include Rack::Test::Methods

  SIMPLE_JSON_TO_EMAIL = '{ "name" : "Terry Pratchett", "status" : "Return to Sender" }'
  SIMPLE_FROM = 'wibble@wibble.wobble'
  SIMPLE_RECIPIENT =  'terrypratchett@discworld.atuin'
  SIMPLE_SUBJECT = 'The Grim Squeaker'



  def app
    @@log.debug("Returning RCMServer instance")
    RCM::RCMServer.new
  end


  def setup
    # Make sure the test mailer is clear and has no outstanding messages
    Mail::TestMailer.deliveries.clear
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

    from = delivery.from[0]
    to = delivery.to[0]
    subject = delivery.subject
    body = delivery.body

    assert(from == SIMPLE_FROM, "From is not correct, is #{from}")
    assert(to == SIMPLE_RECIPIENT, "To is not correct, is #{to}")
    assert(subject == SIMPLE_SUBJECT, "Subject is not correct, is #{subject}")
    assert(body == SIMPLE_JSON_TO_EMAIL, "Body is not correct, is #{body}")
  end

end

