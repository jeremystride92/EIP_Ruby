class ShortUrlCache
  @@cache = {}
  def self.shorten(url, skip_cache: false, **options)
    if skip_cache
      Bitly.client.shorten(url, options)
    else
      search_cache(url) || add_to_cache(url, Bitly.client.shorten(url, options))
    end
  end

  def self.cache
    @@cache
  end

  def self.cache=(cache)
    @@cache = cache
  end


  private

  def self.search_cache(url)
    @@cache[url]
  end

  def self.add_to_cache(url, short_url)
    @@cache[url] = short_url
  end

  class RedisHashCache
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
end
