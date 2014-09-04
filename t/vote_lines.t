ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "MP on Issue" do

  describe "when viewing Tom Watson on EU Integration" do

    before { get '/issue/PW-1065/tom_watson' }

    # Including these all in one method as I can't work out how to make a
    # 'before' that only runs once, and don't want to hit the Morph API
    # repeatedly. I should really mock the response.
    it "should display votes correctly" do
      # described Yes
      last_response.body.must_include 'voted to call on the UK Government to seek a real terms cut in the European Union budget'
      # described No
      last_response.body.must_include 'voted not to commend the Prime Minister for refusing to sign up to an EU Treaty'
      # described Absence
      last_response.body.must_include 'did not vote when the majority of MPs voted to support stronger governance of the Schengen area'
      # undescribed Yes
      last_response.body.must_include 'yes on Lisbon Treaty — Third Reading'
      # undescribed No
      last_response.body.must_include 'no on Lisbon Treaty — Excludes the European Union from imposing an obligation on Parliament'
      # undescribed Absence
      last_response.body.must_include 'did not vote on Lisbon Treaty — Enshrine the Lisbon Treaty into UK law'
    end

  end


end

