require 'sinatra'
require 'sinatra/jsonp'
require 'json'
require 'date'

get '/status' do
	[ 200, "{  simpleJson: 'value' } " ]

end
