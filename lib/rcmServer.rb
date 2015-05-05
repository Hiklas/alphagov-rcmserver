require 'sinatra/base'
require 'sinatra/jsonp'
require 'util/logger'
require 'json'
require 'yaml'


module RCM

	class RCMServer < Sinatra::Base

		RCM_CONFIG_ENV = 'RCM_CONFIG_FILENAME'
		DEFAULT_CONFIG_FILENAME = 'conf/rcm-server.yaml'


		@@log = Util::LoggerLikeJava.new("RCMServer")

		##
		#
		# We need a bootstrap for this filename to load our config
		#
		def self.get_config_filename
			ENV[RCM_CONFIG_ENV] ||= DEFAULT_CONFIG_FILENAME
		end


		configure do

			# This must be passed in using rackup -e "\$configFilename='<filename>'"
			configFilename = get_config_filename

			@@log.debug("Loading yaml config from '#{configFilename}'...")

			@@config = YAML::load(File.read(configFilename))

			@@log.debug("... loaded")

			# Do the configuration for the server here

			@@log.debug("... configured!")

		end



		post '/submitEvidence' do
			posted_data  = request.body.read

			[ 200, returnJson ]
		end


		get '/status' do
			returnJson = "{ '' }"
			[ 200, returnJson ]
		end

	end

end

