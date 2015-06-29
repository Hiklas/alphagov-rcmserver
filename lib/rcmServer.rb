require 'sinatra/base'
require 'util/lumber'
require 'json'
require 'json-schema'
require 'yaml'
require 'yamlEnvironmentParser'
require 'mail'
require 'mustache'


##
#
# Referal Case Management
#
module RCM

	module Constants
		CONFIG_EMAIL = 'email'
		CONFIG_SERVER = 'server'

		CONFIG_DELIVERY = 'delivery_method'
		CONFIG_SMTP_PORT = 'smtp_port'
		CONFIG_SMTP_SERVER = 'smtp_server'
		CONFIG_SMTP_USERNAME = 'smtp_username'
		CONFIG_SMTP_PASSWORD = 'smtp_password'
		CONFIG_EMAIL_DOMAIN = 'domain'

		CONFIG_ADDRESSING = 'address'
		CONFIG_RECIPIENT = 'recipient'
		CONFIG_FROM = 'from'
		CONFIG_SUBJECT = 'subject'
		CONFIG_PGP_KEY = 'pgp'
		CONFIG_DISABLED = 'disabled'

		CONFIG_FORMAT = 'format'
		CONFIG_TEMPLATE = 'template'

		CONFIG_EVIDENCE = 'evidence'
		CONFIG_MINIMUM_LENGTH = 'minimum'
		CONFIG_MAXIMUM_LENGTH = 'maximum'
		CONFIG_LINE_LENGTH = 'line'

		ENV_EMAIL_DISABLED = 'EMAIL_DISABLED'
	end


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


	##
	#
	# Application class for RCM server
	#
	#
	class RCMServer < Sinatra::Base

		include RCM::Constants

		RCM_CONFIG_ENV = 'RCM_CONFIG_FILENAME'
		DEFAULT_CONFIG_FILENAME = 'conf/rcm-server-development.yaml'

		CONFIG_FILE_PATH_BASE = 'conf/rcm-server-'
		CONFIG_FILE_PATH_EXTENSION = '.yaml'

		RACK_ENVIRONMENT = 'RACK_ENV'

		DEFAULT_MINIMUM_LENGTH = 10
		DEFAULT_MAXIMUM_LENGTH = 8000
		DEFAULT_LINE_LENGTH = 80


		include Util::Lumber::LumberJack

		@@log = lumber("RCMServer")


		def self.calculate_config_filename
			rack_environment = ENV[RACK_ENVIRONMENT]
			if rack_environment.nil?
				@@log.debug('No rack environment set, defaulting filename')
				DEFAULT_CONFIG_FILENAME
			else
				@@log.debug('Using rack environment setting: %s', rack_environment)
				"#{CONFIG_FILE_PATH_BASE}#{rack_environment}#{CONFIG_FILE_PATH_EXTENSION}"
			end
		end


		##
		#
		# We need a bootstrap for this filename to load our config
		#
		def self.config_filename
			ENV[RCM_CONFIG_ENV] || calculate_config_filename
		end


		def self.email_server_config(key)
			value = @@config[CONFIG_EMAIL][CONFIG_SERVER][key]
			@@log.debug('Email server config, key=%s, value=%s', key, value)
			value
		end

		def self.email_send_config(key)
			value = @@config[CONFIG_EMAIL][CONFIG_ADDRESSING][key]
			@@log.debug('Email send config, key=%s, value=%s', key, value)
			value
		end

		def self.email_format_config(key)
			value = @@config[CONFIG_EMAIL][CONFIG_FORMAT][key]
			@@log.debug('Email format config, key=%s, value=%s', key, value)
			value
		end

		def self.evidence_config(key)
			value = @@config[CONFIG_EMAIL][key]
			@@log.debug('Email config, key=%s, value=%s', key, value)
			value
		end

		def self.environment_config(key)
			ENV[key]
		end

		def minimum_length
			RCMServer::evidence_config(CONFIG_MINIMUM_LENGTH) || DEFAULT_MINIMUM_LENGTH
		end

		def maximum_length
			RCMServer::evidence_config(CONFIG_MAXIMUM_LENGTH) || DEFAULT_MAXIMUM_LENGTH
		end

		def line_length
			RCMServer::evidence_config(CONFIG_LINE_LENGTH) || DEFAULT_LINE_LENGTH
		end


		def email_from
			RCMServer::email_send_config(CONFIG_FROM)
		end

		def email_recipient
			RCMServer::email_send_config(CONFIG_RECIPIENT)
		end

		def email_subject
			RCMServer::email_send_config(CONFIG_SUBJECT)
		end

		def email_disabled
			# TODO: Bit of a hack here.  Under normal circumstances the status of the email_disabled setting
			# TODO: would just be read from the yaml file.  For testing however, the same Ruby VM is used for all
			# TODO: tests so that once the rcmServer has been created (and the yaml config read) things don't change.
			# TODO: This means that the tests for disabling email won't work as they need to set the environment for
			# TODO: just this run.  For now, we're using this hack (force the environment to be re-read).  Ideally
			# TODO: this test should be run in a new VM, OR we have another mechnanism for configuring the application
			# TODO: that allows runtime changes.
			RCMServer::environment_config(ENV_EMAIL_DISABLED) || RCMServer::email_send_config(CONFIG_DISABLED)
		end

		def email_template
			@@template
		end


		def self.configure_format
			template_filename = email_format_config(CONFIG_TEMPLATE)
			@@log.debug('Reading template file: %s', template_filename)
			@@template = File.read(template_filename)
		end


		def self.configure_email
			mail_method_text = email_server_config(CONFIG_DELIVERY)
			mail_method_sym = (mail_method_text) ? mail_method_text.to_sym : nil

			options = {
					address: email_server_config(CONFIG_SMTP_SERVER),
					port: email_server_config(CONFIG_SMTP_PORT),
					user_name: email_server_config(CONFIG_SMTP_USERNAME),
					password: email_server_config(CONFIG_SMTP_PASSWORD),
					domain: email_server_config(CONFIG_EMAIL_DOMAIN)
			}

			@@log.debug('Configuring email with method \'%s\' and options: %s', mail_method_sym, options)

			Mail.defaults do
				delivery_method mail_method_sym, options
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
			configFilename = config_filename

			@@log.debug('Loading yaml config from "%s" ...', configFilename)

			@@config = YamlEnvironmentParser.parse(File.read(configFilename))

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

			# Avoids returning big HTML rendered pages with stack traces when we get an error
			set :show_exceptions, false

			# Do the configuration for the server here
			configure_environment
			configure_email
			configure_format

			@@log.debug('... configured!')
		end


		post '/submitEvidence' do
			@@log.debug('Submit evidence')

			pipeline_data = read_request_body(request.body)
			pipeline_data = validate_json(pipeline_data.data) if pipeline_data.status
			pipeline_data = generate_form(pipeline_data.data) if pipeline_data.status
			pipeline_data = create_email(pipeline_data.data) if pipeline_data.status
			pipeline_data = send_email(pipeline_data.data) if pipeline_data.status

			if pipeline_data.status
				@@log.debug('Success!')
				pipeline_data.data
			else
				@@log.debug('We got an error')
				pipeline_data.error
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


			def generate_success_response(message)
				[ 200,
					{ 'Content-Type' => 'application/json'},
					'{ "message": "Success" }'
				]
			end


			def read_request_body(body_stringio)
				@@log.debug('Reading request data')

				# Response object
				response = ProcessDataReturnObject.new

				# Buffer for reading body data
				posted_data = ''

				begin
					# TODO: What delimits a line
					body_stringio.each_line(line_length) do |line|
						posted_data += line
						if posted_data.length > maximum_length
							@@log.debug('Read request data: above maximum length')
							raise SubmitException.new(
												generate_error_response(400, 'Data too large'))
						end
					end

					if posted_data.length < minimum_length
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


			def generate_form(json_hash)
				# Response object
				response = ProcessDataReturnObject.new

				begin
					mustache = Mustache.new
					mustache.template = email_template

					json_hash.each_key do |key|
						mustache[key.to_sym] = json_hash[key]
					end

					response.data = mustache.render
					response.status = true

				rescue Exception => ee
					@@log.error('Couldn\'t process template, exception: ', ee)
				end

				# Remember to have response on it's own as the last statement so this is the return object
				response
			end


			def create_email(parsed_data)
				@@log.debug('Creating email')

				# Response object
				response = ProcessDataReturnObject.new

				from_value = email_from
				recipient_value = email_recipient
				subject_value = email_subject

				mail = Mail.new do
					from     from_value
					to       recipient_value
					subject  subject_value
					body     parsed_data
				end

				response.data = mail
				response.status = true

				# Remember to have response on it's own as the last statement so this is the return object
				response
			end


			def send_email(email_data)
				@@log.debug('Sending email')

				# Response object
				response = ProcessDataReturnObject.new

				disabled = email_disabled

				@@log.debug('Email disabled: %s', disabled)

				if disabled == 'true'
					@@log.info('*** Skipping sending of email ***')
					response.data = generate_success_response('Email skipped')
				else
					@@log.debug('About to send the email')
					email_data.deliver!
					response.data = generate_success_response('Email sent')
					@@log.debug('Email sent')
				end

				response.status = true

				# Remember to have response on it's own as the last statement so this is the return object
				response
			end

	end

end

