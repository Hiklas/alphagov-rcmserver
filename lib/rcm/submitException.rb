module RCM

  ##
  #
  # TODO: Do we need this?
  #
  class SubmitException < Exception
    attr_accessor :error_response

    def initialize(error_response)
      @error_response = error_response
    end
  end

end