ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Stance viewer" do

  it "should have a homepage" do
    get '/'
    last_response.body.must_include 'What is this'
  end

end

