
require 'test/unit'
require 'rack/test'
require 'mail'
require 'test_utils'

require 'util/lumber'
require 'rcm/rcmServer'


class RCMServerAppMailDisabledTest < Test::Unit::TestCase

  include Util::Lumber::LumberJack

  @@log = lumber("RCMServerAppMailDisabledTest")

  include Rack::Test::Methods

  # This includes the changeEnv method for testing with different environment variable settings
  include TestUtils

  SIMPLE_JSON_TO_EMAIL = '{ "name" : "Terry Pratchett", "status" : "Return to Sender" }'
  SIMPLE_FROM = 'wibble@wibble.wobble'
  SIMPLE_RECIPIENT =  'terrypratchett@discworld.atuin'
  SIMPLE_SUBJECT = 'The Grim Squeaker'


  def app
    @@log.debug('Returning RCMServer instance')
    serverInstance = RCM::RCMServer.new

    @@log.debug('Returning RCMServer instance: %s', serverInstance)
    serverInstance
  end


  def setup
    # Make sure the test mailer is clear and has no outstanding messages
    Mail::TestMailer.deliveries.clear
  end


  def test_submit_with_simple_json_mail_disabled
    @@log.debug("Testing submit data with simple JSON")

    lastCode = nil

    changeEnv({ 'EMAIL_DISABLED' => 'true' }) do
      @@log.debug('Calling RCMServer with disabled email')
      post '/submitEvidence', SIMPLE_JSON_TO_EMAIL, 'Content Type' => 'application/json'
      lastCode = last_response.status
    end

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 0, "Didn't get 0 delivery, got #{numberDeliveries}")
  end

end

