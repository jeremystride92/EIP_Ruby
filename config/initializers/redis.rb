$redis = Redis.new(:host => 'localhost', :port => 6379)

ShortUrlCache.cache = ShortUrlCache::RedisHashCache.new
