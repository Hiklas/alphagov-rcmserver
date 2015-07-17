module RCM

  ##
  #
  # Tuple to return status and error or data
  #
  # Used as we process the data from the request.  The idea being to form a
  # kind of pipeline where failures short circuit the process and drop out
  # to report an error.
  #
  # TODO: This is probably over-engineering and more for aesthetics than actual
  # TODO: function but I didn't want to have a bunch of if then else clauses so
  # TODO: this class is meant to convey the results of previous processing
  #
  class ProcessDataReturnObject
    attr_accessor :status, :error, :data

    # Note: not bothering with initializing status to false as 'nil' counts
    # as false also.  There is the added advantage that nil can signify the fact
    # that there was no handling of errors done by a step
  end

end