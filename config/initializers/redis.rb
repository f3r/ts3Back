uri = URI.parse(REDISTOGO_URL)
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)