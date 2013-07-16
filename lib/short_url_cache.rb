class ShortUrlCache
  def initialize(cache: RedisHashCache.new)
    @cache = cache
  end

  def shorten(url, skip_cache: false, **options)
    if skip_cache
      Bitly.client.shorten(url, options).short_url
    else
      search_cache(url) || add_to_cache(url, Bitly.client.shorten(url, options).short_url)
    end
  end

  private

  def search_cache(url)
    @cache[url]
  end

  def add_to_cache(url, short_url)
    @cache[url] = short_url
  end
end

class ShortUrlCache::RedisHashCache
  def initialize(redis: $redis, prefix: 'short_url:')
    @prefix = prefix
    @redis = redis
  end

  def [](key)
    @redis.get(@prefix + key)
  end

  def []=(key, value)
    @redis.set(@prefix + key, value)
    value
  end

  def clear
    raise 'No prefix set! Would have deleted all redis keys.' if @prefix.empty?
    @redis.del(@redis.keys("#{@prefix}*"))
  end
end
