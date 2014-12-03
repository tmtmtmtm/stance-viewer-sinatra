ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "API" do

  describe "when getting all issues " do

    before { get '/api/issues' }
    let(:json) { JSON.parse(last_response.body) }
    
    it "should have have at least 60 issues" do
      json.size.must_be :>, 60
    end

  end

  #-------------------------------------------------------------------

  describe "when getting an unknown issue" do

    before { get '/api/issue/PW-0' }

    it "should have a known issue" do
      last_response.status.must_equal 404
    end

  end

  #-------------------------------------------------------------------

  describe "when getting individual issue" do

    before { get '/api/issue/PW-1027' }
    let(:json) { JSON.parse(last_response.body) }

    it "should find a known issue" do
      json['id'].must_equal 'PW-1027'
    end

    it "should be in two categories" do
      json['categories'].must_equal ['summary', 'foreignpolicy']
    end

    it "should have a flickr image" do
      json['image'].must_equal 'https://www.flickr.com/photos/friendly-fire/33431056'
    end

  end

  #-------------------------------------------------------------------


end

