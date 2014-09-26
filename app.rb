require 'sinatra'
require 'redcarpet'
require 'uri'
require 'securerandom'

class Forum < Sinatra::Application
	enable :sessions
end

require_relative 'util/init'
require_relative 'models/init'
require_relative 'routes/init'