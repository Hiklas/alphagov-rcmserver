require 'pp'

module Util

  module Lumber

    module Constants
      TRACE = :trace
      DEBUG = :debug
      INFO = :info
      WARN = :warn
      ERROR = :error
      FATAL = :fatal

      ORDERING = {trace: 5, debug: 4, info: 3, warn: 2, error: 1}
    end

    ##
    #
    # An instance of the logger
    #
    #
    class LumberLogs

      include Constants

      DEFAULT_OUT = STDOUT
      DEFAULT_LEVEL = DEBUG


      # Actually default to DEFAULT_OUT
      @@out = nil

      # Actually defaults to DEFAULT_LEVEL
      @@level = nil

      # Used to track whether pretty printing should be enabled
      @@pp = {}

      def initialize (name)
        @name = name
      end


      def name
        @name
      end

      def trace (message, *args)
        log(TRACE, message, *args)
      end


      def debug(message, *args)
        log(DEBUG, message, *args)
      end


      def warn(message, *args)
        log(WARN, message, *args)
      end


      def info(message, *args)
        log(INFO, message, *args)
      end


      def error(message, *args)
        log(ERROR, message, *args)
      end

      def fatal(message, *args)
        log(FATAL, message, *args)
      end


      def pp(thingToPP, objectToPP)
        if @@pp[thingToPP] == :on
          pp_header(thingToPP)
          Kernel::pp(objectToPP, logger)
          pp_footer(thingToPP)
        end
      end

      def self.get_lumber(name)
        LumberLogs.new(name)
      end

      def self.set_level(level)
        if ORDERING[level].nil?
          raise ConfigError, "No such level as #{level.to_s}"
        end

        @@level = level
      end


      def self.set_output(out)
        @@out = out
      end


      def self.pretty_print_on(thingToPP)
        @@pp[thingToPP] = :on
      end


      def self.pretty_print_off(thingToPP)
        @@pp[thingToPP] = :off
      end

      private

      def log(message_level, message, *args)
        if level_number(message_level) <= current_level_number
          full_message = create_log_message(message_level, message, *args)
          logger.print(full_message)
          logger.print("\n")
        end
      end


      def create_log_message(message_level, message, *args)
        timestamp = get_current_timestamp
        level_string = get_level_string(message_level)
        thread_id = get_thread_id
        log_message = sprintf(message, *args)

        sprintf("[%s]-[%d]-[%s] - %s", timestamp, thread_id, level_string, log_message)
      end

      def get_current_timestamp
        now = Time.now
        now.strftime("%Y-%m-%d %H:%M:%S.%L")
      end

      def get_level_string(level)
        level.to_s.upcase
      end

      def get_thread_id
        # Not actually the thread ID, the process ID
        $$
      end


      def current_level_number
        level_number(current_level)
      end


      def level_number(levelSymbol)
        ORDERING[levelSymbol]
      end


      def logger
        @@out ||= DEFAULT_OUT
      end


      def current_level
        @@level ||= DEFAULT_LEVEL
      end

      def pp_header(thingToPP)
        header = sprintf("%s: >-----------", thingToPP.to_s.upcase)
        logger.puts(header)
      end

      def pp_footer(thingToPP)
        footer = sprintf("%s: -----------<", thingToPP.to_s.upcase)
        logger.puts(footer)
      end
    end


    ##
    #
    # Include this module for logging functionality
    #
    module LumberJack

      # These should be available to anyone that includes
      include Constants

      DEFAULT_LUMBER = "DefaultLogger"

      ##
      #
      # Get the logger.
      #
      # There are too many things called 'log' or 'logger' so going for something
      # different!
      #
      module ClassMethods
        def lumber(name=DEFAULT_LUMBER)
          Util::Lumber::LumberLogs::get_lumber(name)
        end
      end


      def self.lumber_level(level)
        Util::Lumber::LumberLogs::set_level(level)
      end


      def self.lumber_out(out)
        Util::Lumber::LumberLogs::set_output(out)
      end

      def self.pp_on(thingToPP)
        Util::Lumber::LumberLogs::pretty_print_on(thingToPP)
      end

      def self.pp_off(thingToPP)
        Util::Lumber::LumberLogs::pretty_print_off(thingToPP)
      end

      ##
      #
      # This method does magic.
      #
      # When this module is included into a class this method is called with a reference to the Class
      # instance and then extend method (which actually comes from Object) adds the methods from the
      # module above (ClassMethods) into that instance.
      def self.included(base)
        base.extend ClassMethods
      end

    end # LumberJack

  end # Lumber

end # Util

