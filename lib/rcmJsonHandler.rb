require 'json'
require 'json-schema'

require 'util/lumber'
require 'rcmConfig'

require 'processDataReturnObject'
require 'submitException'
require 'responseGenerator'


module RCM

  ##
  #
  # Handle JSON data from the server
  #
  #
  class JsonHandler

    include Util::Lumber::LumberJack

    @@log = lumber("JsonHandler")

    include RCM::ResponseGenerator

    def initialize(rcmConfig)
      @rcmConfig = rcmConfig
    end


    def read_request_body(body_stringio)
      @@log.debug('Reading request data')

      # Response object
      response = ProcessDataReturnObject.new

      # Buffer for reading body data
      posted_data = ''

      begin
        while line = body_stringio.read(@rcmConfig.line_length) do
          posted_data += line
          if posted_data.length > @rcmConfig.maximum_length
            @@log.debug('Read request data: above maximum length')
            raise SubmitException.new(
                      generate_error_response(400, 'Data too large'))
          end
        end

        if posted_data.length < @rcmConfig.minimum_length
          @@log.debug('Read request data: below minimum length: "%s"', posted_data)
          raise SubmitException.new(
                    generate_error_response(400, 'Not enough data provided'))
        end

        # If we get here all is fine
        response.status = true
        response.data = posted_data

      rescue	SubmitException => se
        @@log.debug('Reading request data: got an exception: %s', se)
        response.status = false
        response.error = se.error_response
      end

      # Pass back the response object
      response
    end


    def validate_json(json_text)
      @@log.debug('Validating JSON')

      # Response object
      response = ProcessDataReturnObject.new

      begin
        response.data = JSON.parse(json_text)
        response.status = true
      rescue Exception => ee
        @@log.debug('Couldn\'t parse JSON %s', json_text)
        response.error = generate_error_response(500, ee.to_s)
      end

      # Remember to have response on it's own as the last statement so this is the return object
      response
    end


  end


end