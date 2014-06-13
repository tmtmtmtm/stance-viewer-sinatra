require 'sinatra'
require 'haml'
require 'json'

get '/' do
  haml :index
end

get '/parties.html' do
  @parties = JSON.parse(File.read('data/parties.json'))
  haml :parties
end

get '/people.html' do
  "Members of Parliament"
end

get '/issues.html' do
  @issues = JSON.parse(File.read('data/issues.json'))
  haml :issues
end

get '/about.html' do
  "About"
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




