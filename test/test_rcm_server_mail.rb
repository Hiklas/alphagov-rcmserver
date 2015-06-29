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

  JSON_FILE = 'test/client.post.test.json'
  SIMPLE_JSON_TO_EMAIL = '{ "name" : "Terry Pratchett", "status" : "Return to Sender" }'
  SIMPLE_JSON_TO_EMAIL_RESULT = "TimeStamp: \n"
  SIMPLE_FROM = 'wibble@wibble.wobble'
  SIMPLE_RECIPIENT =  'terrypratchett@discworld.atuin'
  SIMPLE_SUBJECT = 'The Grim Squeaker'
  CHECK_FOR_ENTITIES = /\&.+;/

  def self.read_json
    @@log.debug('Reading file ...')
    result = File.read(JSON_FILE)
    @@log.debug('... Read file')

    result
  end


  def full_json
    result = @@json_text ||= RCMServerAppMailTest::read_json
    @@log.debug('Returning full JSON: %s', result)
    result
  end


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
    assert(body == SIMPLE_JSON_TO_EMAIL_RESULT, "Body is not correct, is '#{body}' expected '#{SIMPLE_JSON_TO_EMAIL_RESULT}'")
  end


  def test_submit_with_simple_json_body_not_json
    @@log.debug("Testing submit data with simple JSON, checking body isn't JSON")
    post '/submitEvidence', SIMPLE_JSON_TO_EMAIL, 'Content Type' => 'application/json'
    lastCode = last_response.status

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first

    body = delivery.body.to_s

    assert(body.index('{').nil?, "Body contains JSON #{body}")
  end


  def test_submit_with_full_json
    @@log.debug("Testing submit data with full JSON, checking body contains correct data")
    post '/submitEvidence', full_json, 'Content Type' => 'application/json'
    lastCode = last_response.status

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first

    body = delivery.body.to_s

    assert(body.index('{').nil?, "Body contains JSON #{body}")
    assert(body.index('TimeStamp') != nil, "Body doesn't contain TimeStamp: '#{body}'")
    assert(body.index('Carrot') != nil, "Body doesn't contain TimeStamp: '#{body}'")
  end


  def test_submit_with_full_json_check_entities
    @@log.debug("Testing submit data with full JSON, checking body contains no entities")
    post '/submitEvidence', full_json, 'Content Type' => 'application/json'
    lastCode = last_response.status

    assert(lastCode == 200, "We got the wrong return code: #{lastCode}")

    deliveries = Mail::TestMailer.deliveries
    assert(deliveries!=nil, "Got nil deliveries")

    numberDeliveries = deliveries.length
    assert(numberDeliveries == 1, "Didn't get 1 delivery, got #{numberDeliveries}")

    delivery = deliveries.first

    body = delivery.body.to_s
    matchedEntities = CHECK_FOR_ENTITIES.match(body)

    @@log.debug('Check for matches: %s', matchedEntities)
    assert(matchedEntities == nil, "Body contains entities: '#{body}'")
  end

end

