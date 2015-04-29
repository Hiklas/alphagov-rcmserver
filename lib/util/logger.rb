require 'logger'


module Util

	class LoggerLikeJava

		def initialize(loggerName)
			@loggerName = loggerName
		end
		
		def debug(message)
			logMessage(:debug, message)
		end
		
		def info(message)
			logMessage(:info, message)
		end
		
		def warn(message)
			logMessage(:warn, message)
		end
		
		def error(message)
			logMessage(:error, message)		
		end
	
	  def stack(level = :debug)
	    message = ""
      Kernel::caller.each do |stack|
        message << "  #{stack}\n"
      end
      logMessage(level, "Stack: #{message}\n")
	  end
	  
	  def level=(level)
      LoggerLikeJava::logger.level=level	  
	  end
	  
	  def level
	    LoggerLikeJava::logger.level
	  end
	  
	  
		private
		
			def logMessage(method, message)
				fullMessage = "#{@loggerName} - #{message}"
				self.class.logger.send(method, fullMessage)			
			end
			
			# 
			# Accessor for the logger instance
			#
			def self.logger 
				@@loggerInstance ||= LoggerLikeJava.createLogger		
			end

			# 
			# For now the logger will always write to STDOUT
			# this could do with being configurable
			#			
			def self.createLogger
			  # Needed to ensure that data is written immediately
			  STDOUT.sync = true
				@@loggerInstance = Logger.new(STDOUT)
			end 
	end
	
end