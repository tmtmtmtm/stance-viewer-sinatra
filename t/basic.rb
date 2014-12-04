ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "Stance viewer" do

  describe "when viewing the home page" do

    before { get '/' }

    it "should have show some text" do
      last_response.body.must_include 'What is this'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing the MP list page" do

    before { get '/people.html' }

    it "should have John Bercow" do
      last_response.body.must_include 'John Bercow'
    end
  end

  #-------------------------------------------------------------------

  describe "when viewing the issues page" do

    before { get '/issues.html' }

    it "should have a known issue" do
      last_response.body.must_include 'alcoholic drinks'
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an MP page" do

    before { get '/person/john_bercow' }

    it "should have have their name" do
      last_response.body.must_include 'John Bercow'
    end

    it "should have their party history" do
      last_response.body.gsub(/\s+/, ' ').must_match /Conservative Party \( \– 2009 \)/m
    end

    it "should include Speaker position" do
      last_response.body.must_match /Speaker\s+\(\s+2009/m
    end

    it "should have issues" do
      last_response.body.must_match /strongly against.*hunting ban/
    end

  end

  #-------------------------------------------------------------------

  describe "when viewing an Issue page" do

    before { get '/issue/PW-811' }

    it "should have have its title" do
      last_response.body.must_include 'smoking bans'
    end

    it "should have party stances" do
      last_response.body.must_match /Green Party.*very strongly for/
    end

  end

  #-------------------------------------------------------------------


end

