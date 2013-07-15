class ShortUrlCache
  def self.shorten(url, skip_cache: false, **options)
    @cache ||= {}
    if skip_cache
      Bitly.client.shorten(url, options)
    else
      search_cache(url) || add_to_cache(url, Bitly.client.shorten(url, options))
    end
  end

  def self.cache
    @cache ||= {}
  end

  def self.cache=(cache)
    @cache = cache
  end


  private

  def self.search_cache(url)
    @cache[url]
  end

  def self.add_to_cache(url, short_url)
    @cache[url] = short_url
  end


end
