Rack::Attack.blocklist_ip('1.2.3.4')
Rack::Attack.blocklist_ip('172.26.10.249') # 2019/04/09 17:49 辞書型URL攻撃
Rack::Attack.blocklist_ip('172.26.18.5') # 2019/04/09 19:20 辞書型URL攻撃

class Rack::Attack
  throttle('req/ip', limit: 100, period: 1.minutes) do |req|
    req.ip
  end
end



