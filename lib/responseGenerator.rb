require 'json'

module RCM

  module ResponseGenerator

    def generate_error_response(code, message)
      [ code,
        { 'Content-Type' => 'application/json'},
        generate_error_json(code, message)
      ]
    end


    def generate_error_json(code, message)
      error_response = {
          'error' => code,
          'message' => message
      }
      JSON.generate(error_response)
    end


    def generate_success_response(message)
      [ 200,
        { 'Content-Type' => 'application/json'},
        '{ "message": "Success" }'
      ]
    end

  end

end