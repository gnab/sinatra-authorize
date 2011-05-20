$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'sinatra/base'
require 'sinatra/authorize'

module SpecHelper
  def app
    @app ||= Sinatra::Application
  end

  def reset!
    @app = nil
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SpecHelper
end
