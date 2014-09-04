require 'sinatra'
require 'haml'
require 'json'
require 'open-uri/cached'
require 'colorize'

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

  @issue_info = issue_info(issueid.sub('PW-',''))
  party_id = most_recent_party(@person)
  @party = party_from_id(party_id)
  @stance = person_stances(@person).find { |s| s['id'] == issueid } 
  @party_stance = party_stances(@party).find { |s| s['id'] == issueid }
  @hist   = party_histogram(@issue, @party)
  @votes  = person_votes(@person, @issue)
  haml :issue_mp
end

get '/issue/:id' do |id|
  @issue = issue_from_id(id) or pass
  @stances = issue_stances(@issue)
  haml :issue
end

get '/api/motions' do
  content_type :json
  motion_search(params[:s].gsub("'",'%')) # TODO better protection
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
    }.reject { |s| s['num_votes'].zero? }
  end

  def party_member_stances(issue, party)
    i = json_file('mpstances').detect { |i| i['id'] == issue['id'] } 
    all_member_ids = party_members(party).map { |m| m['id'] }
    return i['stances'].select { |mp,s| all_member_ids.include? mp }
  end

  def party_histogram(issue, party)
    party_member_stances(issue, party).reject { |mp, s| s['num_votes'].zero? }.group_by { |mp, s| stance_text(s) }
  end

  def public_whip_id(person)
    i = person['other_identifiers'].find { |i| i['scheme'] == 'publicwhip.org' } or return
    i['identifier']
  end


  def person_stances(person)
    json_file('mpstances').find_all {|i| i['stances'].has_key? person['id'] }.map { |i|
      i['stances'][person['id']].merge({
        "id" => i['id'],
        "text" => i['html'],
        "stance_text" => stance_text(i['stances'][person['id']]),
      })
    }.reject { |s| s['num_votes'].zero? }
  end

  def issue_stances(issue)
    @issue['stances'].reject { |k,v| k[/peaker/] }.map { |k, v|
      v.merge({
        "party" => party_from_id(k),
        "stance_text" => stance_text(v)
      })
    }.reject { |s| s['num_votes'].zero? }
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

  def most_recent_party(person)
    person['memberships'].find_all { 
      |m| m['role'] == 'MP' 
    }.sort_by { 
      |m| m['start_date'] || '1000-01-01'
    }.reverse.first['organization_id']
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

  require 'csv'
  def issue_info(issueid)
    CSV.foreach('data/spreadsheet.csv') do |row|
      next unless row[0] == issueid
      return row
    end
    return
  end


  require 'open-uri'
  require 'erb'

  def morph_select(qs)
    query = qs.gsub(/\s+/, ' ').strip
    morph_api_key = ENV['MORPH_API_KEY'] or raise "Need a Morph API key"
    key = ERB::Util.url_encode(morph_api_key)
    url = 'https://api.morph.io/tmtmtmtm/publicwhip_policies/data.json' + "?key=#{key}&query=" + ERB::Util.url_encode(query)
    warn "Fetching #{url}".yellow
    return open(url).read
  end

  def motion_search(query_string)
    s = query_string.gsub("'",'%') # TODO better protection
    query = "SELECT *, GROUP_CONCAT(policy) AS policies FROM data WHERE text LIKE '%#{s}%' GROUP BY id ORDER BY datetime DESC LIMIT 30"
    morph_select(query)
  end

  def morph_votes(personid, issueid)
    query = <<-eosql
      SELECT DISTINCT m.text, m.datetime, v.motion, v.option, m.shortdesc, m.result
        FROM votes v
        JOIN voters mp ON v.url = mp.url
        JOIN data m ON v.motion = m.id
       WHERE m.policy = #{issueid.to_i}
         AND mp.id = #{personid.to_i}
       ORDER BY m.datetime DESC
    eosql
    JSON.parse( morph_select(query) )
  end

  def vote_display(v)
    fallback = "#{v['option']} on #{v['text']}"
    aye_txt = v['desc']['aye'].empty? ? fallback : v['desc']['aye'] 
    return "voted #{aye_txt}" if v['option'] == 'yes' 

    nay_txt = v['desc']['aye'].empty? ? fallback : v['desc']['nay'] 
    return "voted #{nay_txt}" if v['option'] == 'no'

    maj_txt = v['desc']['aye'].empty? ? "on #{v['text']}" : "when the majority of MPs voted " + (v['result'] == 'passed' ? aye_txt : nay_txt)

    return "did not vote #{maj_txt}" if v['option'] = 'absent'
    return "voted both yes and no #{maj_txt}" if v['option'] = 'both'
    raise "Don't know how to display vote"
  end

  def person_votes(person, issue)
    described_votes = json_file('pw_divisions')
    morph_votes(public_whip_id(person), issue['id'].gsub(/^PW-/,'')).map do |v|
      v['datetime'] = DateTime.parse(v['datetime'])
      # motion is of the form: pw-2003-01-08-42
      md = v['motion'].match(/pw-(?<date>\d{4}-\d{2}-\d{2})-(?<number>\d+)/) or raise "weird motion id: #{v['motion']}"
      v['pw_url'] = 'http://www.publicwhip.org.uk/division.php?date=%s&number=%d' % [md[:date], md[:number]]
      v['desc'] = described_votes.find { |dv| 
        dv['date'] == md[:date] && dv['number'].to_i == md[:number].to_i 
      } || {'aye' => '', 'nay' => ''}
      v['display_text'] = vote_display(v)
      v
    end
  end


end



