require 'sinatra'
require 'haml'
require 'json'

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
  parties = json_file('parties')
  @party = parties.detect { |p| p['id'] == id } or pass
  @members = json_file('people').find_all { |mp| 
    mp['memberships'].detect { |mem| mem['organization_id'] == id } 
  }
  @stances = json_file('partystances').map { |s|
    s['stances'][id].merge({
      "id" => s['id'],
      "text" => s['html'],
      "stance_text" => stance_text(s['stances'][id]),
    })
  }
  haml :party
end

get '/person/:id' do |id|
  people = json_file('people')
  @person = people.detect { |p| p['id'] == id } or pass

  parties = json_file('parties')
  @person['memberships'].each { |mem|
    mem['party'] = parties.detect { |org| org['id'] == mem['organization_id'] }
    mem['party']['name'] = 'Independent' if mem['organization_id'] == 'ind' 
    mem['start_date'] = Date.iso8601(mem['start_date']) if mem['start_date']
    mem['end_date']   = Date.iso8601(mem['end_date'])   if mem['end_date']
  }

  @stances = json_file('mpstances').find_all {|s| s['stances'].has_key? id }.map { |s|
    s['stances'][id].merge({
      "id" => s['id'],
      "text" => s['html'],
      "stance_text" => stance_text(s['stances'][id]),
    })
  }
  haml :person
end

get '/issue/:id' do |id|
  id
end


helpers do
  def json_file(file)
    JSON.parse(File.read("data/#{file}.json"))
  end

  def stance_text(stance)
    return "has never voted on"           if stance['num_votes'].zero?
    return "very strongly for"            if stance['weight'] > 0.95
    return "strongly for"                 if stance['weight'] > 0.85
    return "moderately for"               if stance['weight'] > 0.6
    return "a mixture of for and against" if stance['weight'] > 0.4
    return "moderately against"           if stance['weight'] > 0.15
    return "strongly against"             if stance['weight'] > 0.05
    return "very strongly against"        
  end

end



