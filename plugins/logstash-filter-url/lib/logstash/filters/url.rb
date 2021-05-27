# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "lru_redux"
require "uri"

# The Url filter adds information about the fingerprint of URL,
# based on data from the Wappaplzer database.

class LogStash::Filters::Url < LogStash::Filters::Base
  config_name "url"

  # URL来源字段
  # source => 'url'
  config :source, :validate => :string, :default => 'url'

  # URL 模板字段名
  # url_tpl_name => 'url_tpl'
  config :url_tpl_name, :validate => :string, :default => 'url_tpl'

  # URL路径字段
  # path_name => 'path'
  config :path_name, :validate => :string, :default => 'path'

  # URL站点字段
  # site_name => 'site'
  config :site_name, :validate => :string, :default => 'site'

  # set the size of cache for successful requests
  config :hit_cache_size, :validate => :number, :default => 256

  # how long to cache successful requests (in seconds)
  config :hit_cache_ttl, :validate => :number, :default => 60

  # cache size for failed requests 
  config :failed_cache_size, :validate => :number, :default => 32
 
  # how long to cache failed requests (in seconds) 
  config :failed_cache_ttl, :validate => :number, :default => 5 

  # Tags the event on failure to look up finger information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_url_lookup_failure"]

  public
  def register
    if @hit_cache_size > 0 
      @hit_cache = LruRedux::TTL::ThreadSafeCache.new(@hit_cache_size, @hit_cache_ttl) 
    end 

    if @failed_cache_size > 0 
      @failed_cache = LruRedux::TTL::ThreadSafeCache.new(@failed_cache_size, @failed_cache_ttl) 
    end
  end # def register

  public
  def filter(event)
    url = event.get(@source)
    if url.nil? or url.empty?
      @tag_on_failure.each{|tag| event.tag(tag)}
      @logger.warn("Url filter could not resolve missing url", :source => source)
      return
    end

    default = '{}'

    begin
      uri = URI.parse(URI.escape(url))

      query = ''
      form = nil
      
      if !uri.query.nil?
        form = URI.decode_www_form(uri.query)
        params = Array.new
      
        for ary in form
          params.push(ary[0])
        end
      
        params = params.sort
      
        nform = Array.new
      
        for ary in params
          nform.push(Array[ary, default])
        end
      
        query = '?' + URI.encode_www_form(nform)
      end 
      
      site = "#{uri.scheme}://#{uri.host}"
      if (uri.scheme == 'http' and uri.port != 80) or (uri.scheme == 'https' and uri.port != 443)
        site = "#{site}:#{uri.port}"
      end

      url_tpl = "#{site}#{uri.path}#{query}"
      if !uri.fragment.nil?
        url_tpl = "#{url_tpl}##{uri.fragment}"
      end

      event.set(@path_name, uri.path)
      event.set(@url_tpl_name, url_tpl)
      event.set(@site_name, site)
      
    rescue => e
      @logger.warn("Url result parse failed", :uri => uri, :message => e.message, :stack => e.backtrace.join("\n"))
      @tag_on_failure.each{|tag| event.tag(tag)}
      return
    end
  end

end # class LogStash::Filters::Url
