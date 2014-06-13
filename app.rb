require 'sinatra'
require 'haml'
require 'json'

helpers do
  def json_file(file)
    JSON.parse(File.read("data/#{file}.json"))
  end
end

get '/' do
  haml :index
end

get '/parties.html' do
  @parties = json_file('parties')
  haml :parties
end

get '/people.html' do
  @parties = json_file('parties')
  @people = json_file('people')
  haml :people
end

get '/issues.html' do
  @issues = json_file('issues')
  haml :issues
end

get '/about.html' do
  haml :about
end

get '/party/:id' do |id|
  id
end

get '/person/:id' do |id|
  id
end

get '/issue/:id' do |id|
  id
end




