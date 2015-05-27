require 'sinatra/base'
require 'util/lumber'
require 'json'
require 'json-schema'
require 'yaml'
require 'yamlEnvironmentParser'
require 'mail'



module RCM

	module Constants
		CONFIG_EMAIL = 'email'
		CONFIG_DELIVERY = 'delivery_method'
		CONFIG_SMTP_PORT = 'smtp_port'
		CONFIG_SMTP_SERVER = 'smtp_server'
		CONFIG_SMTP_USERNAME = 'smtp_username'
		CONFIG_SMTP_PASSWORD = 'smtp_password'
		CONFIG_EMAIL_DOMAIN = 'domain'
	end


	class SubmitException < Exception
	end


	##
	#
	# Application class for RCM server
	#
	#
	class RCMServer < Sinatra::Base

		include RCM::Constants

		RCM_CONFIG_ENV = 'RCM_CONFIG_FILENAME'
		DEFAULT_CONFIG_FILENAME = 'conf/rcm-server-dev.yaml'

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


		def self.get_email_config(key)
			value = @@config[CONFIG_EMAIL][key]
			@@log.debug('Email config, key=%s, value=%s', key, value)
			value
		end


		def self.configure_email
			mail_method = get_email_config(CONFIG_DELIVERY)

			options = {
					address: get_email_config(CONFIG_SMTP_SERVER),
					port: get_email_config(CONFIG_SMTP_PORT),
					user_name: get_email_config(CONFIG_SMTP_USERNAME),
					password: get_email_config(CONFIG_SMTP_PASSWORD),
					domain: get_email_config(CONFIG_EMAIL_DOMAIN)
			}

			Mail.defaults do
				delivery_method mail_method, options
			end
		end


		def self.configure_environment
			ENV.each_key do |key|
				@@log.debug('Environment, key=%s, value=%s', key, ENV[key])
			end
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

			@@config = YamlEnvironmentParser.parse(File.read(configFilename))

			configure_environment
			configure_email

			if settings.development?
				@@log.debug('** Development **')
			end

			if settings.test?
				@@log.debug('** Test **')
			end

			if settings.production?
				@@log.debug('** Production **')
			end


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

