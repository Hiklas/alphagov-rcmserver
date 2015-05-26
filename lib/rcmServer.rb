require 'sinatra/base'
require 'util/lumber'
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

		include Util::Lumber::LumberJack

		@@log = lumber("RCMServer")


		##
		#
		# We need a bootstrap for this filename to load our config
		#
		def self.get_config_filename
			ENV[RCM_CONFIG_ENV] ||= DEFAULT_CONFIG_FILENAME
		end


		def initialize
			super
			@@log.debug('RCMServer Instance created')
		end

		##
		#
		# Configure the Sinatra Application
		#
		configure do

			# This must be passed in using rackup -e "\$configFilename='<filename>'"
			configFilename = get_config_filename

			@@log.debug('Loading yaml config from "%s" ...', configFilename)

			@@config = YAML::load(File.read(configFilename))

			@@log.debug('... loaded')


			set :show_exceptions, false

			# Do the configuration for the server here

			@@log.debug('... configured!')
		end


		post '/submitEvidence' do
			@@log.debug('Submit evidence')

			@@log.debug('Request body: %s', request.body)

			posted_data  = request.body.read

			@@log.debug('Read posted data: %s', posted_data)
			@@log.debug('Checking length')

			if posted_data.length < MINIMUM_LENGTH
				generate_error_response(400, 'Not enough data provided')
			end
		end


		get '/status' do
			@@log.debug('Status')

			returnJson = '{ "status" : "Testing status" }'
			[ 200, returnJson ]
		end

		not_found do
			@@log.debug('Not found')
			generate_error_response(404, "Resource '#{request.fullpath}' not found")
		end

		error do
			@@log.error('Application error')
			generate_error_response(500, 'Application error')
		end

		private

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

	end

end

