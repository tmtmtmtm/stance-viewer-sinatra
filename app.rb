require 'sinatra'
require 'haml'
require 'json'
require 'open-uri/cached'

get '/' do
  haml :index
end

get '/editor.html' do
  haml :editor
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
  @party = party_from_id(id) or pass
  @members = party_members(@party)
  @stances = party_stances(@party) 
  haml :party
end

get '/person/:id' do |id|
  @person = person_from_id(id) or pass
  expand_memberships!(@person)
  @stances = person_stances(@person)
  haml :person
end

get '/person/*/vs/*' do |id1,id2|
  @p1 = person_from_id(id1) or pass
  @p2 = party_from_id(id2) or pass
  s1 = person_stances(@p1) 
  s2 = party_stances(@p2) 
  @merged = (s1 + s2).group_by { |s| s['id'] }.reject { |k,v| v.count != 2 }
  haml :person_party
end

get '/compare/*/*' do |id1,id2|
  @p1 = party_from_id(id1) or pass
  @p2 = party_from_id(id2) or pass
  s1 = party_stances(@p1) 
  s2 = party_stances(@p2) 
  @merged = (s1 + s2).group_by { |s| s['id'] }.reject { |k,v| v.count != 2 }
  haml :compare
end

get '/issue/:issue/:person' do |issueid, mpid|
  @issue  = issue_from_id(issueid) or pass
  @person = person_from_id(mpid) or pass
  @stance = person_stances(@person).find { |s| s['id'] == issueid } 
  @party_stances = issue_stances(@issue)
  haml :issue_mp
end

get '/issue/:id' do |id|
  @issue = issue_from_id(id) or pass
  @stances = issue_stances(@issue)
  haml :issue
end

require 'open-uri'
require 'erb'
get '/api/motions' do
  content_type :json
  s = params[:s].gsub("'",'%') # TODO better protection
  query = "SELECT *, GROUP_CONCAT(policy) AS policies FROM data WHERE text LIKE '%#{s}%' GROUP BY id ORDER BY datetime DESC LIMIT 30"
  morph_api_key = ENV['MORPH_API_KEY'] or raise "Need a Morph API key"
  key = ERB::Util.url_encode(morph_api_key)
  url = 'https://api.morph.io/tmtmtmtm/publicwhip_policies/data.json' + "?key=#{key}&query=" + ERB::Util.url_encode(query)
  warn "Fetching #{url}"
  return open(url).read
end
  

helpers do
  def json_file(file)
    JSON.parse(File.read("data/#{file}.json"))
  end

  def party_from_id(id)
    json_file('parties').detect { |p| p['id'] == id } 
  end

  def person_from_id(id)
    json_file('people').detect { |p| p['id'] == id } 
  end

  def issue_from_id(id)
    json_file('partystances').detect { |i| i['id'] == id } 
  end

  def party_stances(party)
    json_file('partystances').find_all { |s| s['stances'].has_key? party['id'] }.map { |s|
      s['stances'][party['id']].merge({
        "id" => s['id'],
        "party" => party,
        "text" => s['html'],
        "stance_text" => stance_text(s['stances'][party['id']]),
      })
    }
  end

  def person_stances(person)
    json_file('mpstances').find_all {|s| s['stances'].has_key? person['id'] }.map { |s|
      s['stances'][person['id']].merge({
        "id" => s['id'],
        "text" => s['html'],
        "stance_text" => stance_text(s['stances'][person['id']]),
      })
    }
  end

  def issue_stances(issue)
    @issue['stances'].reject { |k,v| k[/peaker/] }.map { |k, v|
      v.merge({
        "party" => party_from_id(k),
        "stance_text" => stance_text(v)
      })
    }
  end

  def party_members(party)
    json_file('people').find_all { |mp| 
      mp['memberships'].detect { |mem| mem['organization_id'] == party['id'] } 
    }
  end

  def expand_memberships!(person)
    person['memberships'].each { |mem|
      mem['party'] = party_from_id(mem['organization_id']) || {}
      # If not a real party (e.g. Speaker)
      mem['party']['name'] ||= mem['organization_id'].capitalize
      mem['party']['name'] = 'Independent' if mem['organization_id'] == 'ind' 
      mem['start_date'] = Date.iso8601(mem['start_date']) if mem['start_date']
      mem['end_date']   = Date.iso8601(mem['end_date'])   if mem['end_date']
    }
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



