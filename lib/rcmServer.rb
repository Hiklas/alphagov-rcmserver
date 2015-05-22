require 'sinatra/base'
require 'util/logger'
require 'json'
require 'json-schema'
require 'yaml'


module RCM

	class SubmitException < Exception
	end


	##
	#
	# Application class for RCM server
	#
	#
	class RCMServer < Sinatra::Base

		RCM_CONFIG_ENV = 'RCM_CONFIG_FILENAME'
		DEFAULT_CONFIG_FILENAME = 'conf/rcm-server.yaml'

		MINIMUM_LENGTH = 10


		@@log = Util::LoggerLikeJava.new("RCMServer")

		##
		#
		# We need a bootstrap for this filename to load our config
		#
		def self.get_config_filename
			ENV[RCM_CONFIG_ENV] ||= DEFAULT_CONFIG_FILENAME
		end


		def self.get_mail_config_method
			(ENV["RACK_ENV"] == "production") ? "environment" : "config"
		end

		def self.configureEmail
			config_method = get_mail_config_method
			case config_method

				when "production"
					configureEmail_environment

				when "config"
					configureEmail_config

				else
					@@log.error("Didn't recognise configure method for email: #{config_method}")
			end
		end


		def self.configureEmail_environment


		end


		def self.configureEmail_config

		end


		def initialize
			super
			@@log.debug("RCMServer Instance created")
		end

		##
		#
		# Configure the Sinatra Application
		#
		configure do

			# This must be passed in using rackup -e "\$configFilename='<filename>'"
			configFilename = get_config_filename

			@@log.debug("Loading yaml config from '#{configFilename}'...")

			@@config = YAML::load(File.read(configFilename))

			# TODO: Currently we have to be messy and load config from environment variables OR config file
			configureEmail

			@@log.debug("... loaded")


			set :show_exceptions, false

			# Do the configuration for the server here

			@@log.debug("... configured!")
		end


		post '/submitEvidence' do
			@@log.debug("Submit evidence")

			@@log.debug("Request body: #{request.body}")

			posted_data  = request.body.read

			@@log.debug("Read posted data: #{posted_data}")
			@@log.debug("Checking length")

			if posted_data.length < MINIMUM_LENGTH
				generate_error_response(400, "Not enough data provided")
			end
		end


		get '/status' do
			@@log.debug("Status")

			returnJson = '{ "status" : "Testing status" }'
			[ 200, returnJson ]
		end

		not_found do
			@@log.debug("Not found")
			generate_error_response(404, "Resource '#{request.fullpath}' not found")
		end

		error do
			@@log.error("Application error")
			generate_error_response(500, "Application error")
		end

		private

			def generate_error_response(code, message)
				[ code,
					{ "Content-Type" => "application/json"},
					generate_error_json(code, message)
				]
			end

			def generate_error_json(code, message)
				error_response = {
						"error" => code,
						"message" => message
				}
				JSON.generate(error_response)
			end

	end

end

