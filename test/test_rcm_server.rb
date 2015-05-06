require 'util/logger'
require 'rcmServer'
require 'test/unit'
require 'rack/test'

class RCMServerAppTest < Test::Unit::TestCase

  @@log = Util::LoggerLikeJava.new("RCMServerAppTest")

  HTML_DETECTION_RE = /<html>|<div>|<body>|<p>/

  # TODO: This will match JSONP as well, maybe we don't want that
  JSON_DETECTION_RE = /^\{.+\}/

  include Rack::Test::Methods

  def app
    @@log.debug("Returning RCMServer class")
    RCM::RCMServer
  end

  def test_status
    @@log.debug("Testing status")
    get '/status'
    assert_equal '{ "status" : "Testing status" }', last_response.body
  end

  def test_status_with_params
    @@log.debug("Testing status with parameters")
    get '/status', :name => 'Frank'
    assert_equal '{ "status" : "Testing status" }', last_response.body
  end

  def test_submit_with_empty
    @@log.debug("Testing submit data with empty body")
    post '/submitEvidence', '', 'Content Type' => 'application/json'
    lastCode = last_response.status
    assert(lastCode == 400, "We got the wrong return code: #{lastCode}")
  end

  def test_status_no_html
    @@log.debug("Testing status contains no html")
    get '/status'
    check_no_html_in_body
  end

  def test_incorrect_resource_no_html
    @@log.debug("Testing a failure doesn't result in a HTML page")
    get '/wibble_blah_blergh'
    check_no_html_in_body
  end

  def test_json_returned_incorrect_resource
    @@log.debug("Testing JSON returned")
    get '/wibble_blah_blergh'
    check_json_in_body
  end

  ##
  #
  # Rather than sending back rendered HTML for errors we want JSON with
  # an error message.  Check there is no HTML in the body.
  #
  def check_no_html_in_body
    found_html = check_body_for(HTML_DETECTION_RE)
    assert(found_html == false, "Found html in body: #{last_response.body}")
  end


  ##
  #
  # Expect JSON in the body of the response whether we get an error
  # or not.
  #
  def check_json_in_body
    found_json = check_body_for(JSON_DETECTION_RE)
    assert(found_json == true, "Didn't find JSON in body: #{last_response.body}")
  end


  def check_body_for(check_regular_expression)
    found_html = false
    body = last_response.body

    if body.respond_to?(:to_str)
      found_html |= check_re_in_string(check_regular_expression, body.to_str)
    elsif body.respond_to?(:each)
      body.each do |body_part|
        found_html |= check_re_in_string(check_regular_expression, body_part.to_str)
      end
    else
      @@log.error("Could not handle a body of type #{body.class.to_str}")
      fail("Got a body class we didn't understand")
    end
  end

  def check_re_in_string(check_regular_expression, string_to_check)
    (string_to_check =~ check_regular_expression) != nil
  end

end

