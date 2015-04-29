require 'sinatra/base'
require 'sinatra/jsonp'
require 'util/logger'
require 'json'
require 'yaml'


module RCM

	class RCMServer < Sinatra::Base

		@@log = Util::LoggerLikeJava.new("RCMServer")

		configure do

			# This must be passed in using rackup -e "\$configFilename='<filename>'"
			configFilename = $configFilename

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
			returnJson = get_server_status
			[ 200, returnJson ]
		end


		private



	end

end

