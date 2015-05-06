$:.unshift File.expand_path("./lib", File.dirname(__FILE__))

require 'rcmServer'

use Rack::Static, :urls => ['/html', '/javascript', '/css'], :root => 'public'

run RCM::RCMServer
