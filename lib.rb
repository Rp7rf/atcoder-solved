
require 'net/http'
require 'uri'
require 'json'

def get_users
  [
    'rika0384',
    'shumon_84',
    'ixmel_rd',
    'tuki_remon',
    'noy72',
    'uchi',
    'yuiop',
    'yebityon',
    'vvataarne',
    'kuma13',
    'fuu32',
    'Oike7',
    'Masumi',
    'takaya',
  ]
end

def get_file # 本番では消す
  begin
    str = ''
    File.open('save.json') do |file|
      str = file.read
    end
    return str
  rescue SystemCallError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  rescue IOError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  end
end

def checkContest(type, contest_name)
  return false if type.empty?
  if type == 'other' # その他のコンテスト
    return false if ['arc', 'agc', 'abc'].all?{|contest| 
      contest_name.match(contest).nil?
    }
  else # 指定されたコンテスト
    return false if contest_name.match(type)
  end
  return true
end

def getResults(type = '')
  root = 'http://beta.kenkoooo.com/atcoder/atcoder-api/results?user=&rivals='
  puts root + get_users.join(',')

  uri = URI.parse(root + get_users.join(','))
  # puts Net::HTTP.get(uri)
  results = JSON.parse(Net::HTTP.get(uri))
  # problems = getProblems(type)
  # results = JSON.parse(get_file())
  results.map{|problem|  
    next if problem['result'] != 'AC'
    next if checkContest(type, problem['contest_id']) # 判定
    next if problems[problem['contest_id']]['problem'][problem['problem_id']].nil? # 判定
    problems[problem['contest_id']]['problem'][problem['problem_id']][:accept] << problem['user_id']
  }
  return problems
end

def getContests(type = '')
  root = 'http://kenkoooo.com/atcoder/atcoder-api/info/contests'

  uri = URI.parse(root)
  results = JSON.parse(Net::HTTP.get(uri))
  keys = ["start_epoch_second", "id", "title"]
  contests = results.map{|result|
    next if checkContest(type, result['id']) # 判定
    contest = {}
    [result['id'], keys.map{|key| [key, result[key] ]}.to_h]
  }.reject{|c| c.nil? }.sort_by{|k,v| k}.to_h

end

def getProblems(type='')
  root = 'http://kenkoooo.com/atcoder/atcoder-api/info/problems'

  uri = URI.parse(root)
  results = JSON.parse(Net::HTTP.get(uri))
  contests = getContests(type).map{|k,contest | 
    contest['problem'] = [] 
    [k,contest]
  }.to_h
  results.map{|result|
    next if checkContest(type, result['id']) # 判定
    contests[result['contest_id']]['problem'] << [result['id'], {'id': result['id'], 'title': result['title'], 'contest_id': result['contest_id'], 'accept': []}]
  }.reject{|c| c.nil?}#.sort_by{|k,v| k }.to_h
  contests.map{|k,v|
    v['problem'] = v['problem'].sort_by{|k,v| k}.to_h
    [k,v]
  }.to_h
end
# getProblems('other').map{|k,v|
#   puts v['problem']
# }
getResults('other').map{|k, contest|
  contest['problem'].map{|kk, problem|
    puts problem
  }
}