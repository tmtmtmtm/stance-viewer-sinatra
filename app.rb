require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/parties.html' do
  "Political parties"
end

get '/people.html' do
  "Members of Parliament"
end

get '/issues.html' do
  "Issues"
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




