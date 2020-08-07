# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "lru_redux"
require 'ipaddr'

# The Ip filter adds information about the fingerprint of URL,
# based on data from the Ip database.

class LogStash::Filters::Ip < LogStash::Filters::Base
  config_name "ip"

  # IP 字段
  # source => 'ip'
  config :source, :validate => :string, :default => 'ip'

  # 内网IP标识输出字段名
  # inner_name => 'inner'
  config :inner_name, :validate => :string, :default => 'inner'

  # 内网 IP 地址范围定义
  # inner_ips = 'x.x.x.x-x.x.x.x,x.x.x.x'
  config :inner_ips, :validate => :string, :default => nil

  # set the size of cache for successful requests
  config :hit_cache_size, :validate => :number, :default => 256

  # how long to cache successful requests (in seconds)
  config :hit_cache_ttl, :validate => :number, :default => 60

  # cache size for failed requests 
  config :failed_cache_size, :validate => :number, :default => 32
 
  # how long to cache failed requests (in seconds) 
  config :failed_cache_ttl, :validate => :number, :default => 5 

  # Tags the event on failure to look up finger information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_ip_lookup_failure"]
  
  attr_reader :hit_cache 
  attr_reader :failed_cache 

  public
  def register
    if @inner_ips.nil?
      @inner_ips = '10.0.0.0-10.255.255.255,172.16.0.0-172.31.255.255,192.168.0.0-192.168.255.255,169.254.0.0-169.254.255.255,127.0.0.1-127.0.0.255'
    end

    @inner_ip_list = @inner_ips.split(',')
    @inner_ip_list.each_index do |index|
      inner_ip_range = @inner_ip_list[index].split('-')
      if inner_ip_range.size == 2
        inner_start, tmp_start = ip_convert(inner_ip_range[0])
        inner_end, tmp_start = ip_convert(inner_ip_range[1])
        @inner_ip_list[index] = [inner_start, inner_end]
      else
        inner_ip, tmp_ip = ip_convert(inner_ip_range[0])
        @inner_ip_list[index] = [inner_ip, inner_ip]
      end
    end

    if @hit_cache_size > 0 
      @hit_cache = LruRedux::TTL::ThreadSafeCache.new(@hit_cache_size, @hit_cache_ttl) 
    end 

    if @failed_cache_size > 0 
      @failed_cache = LruRedux::TTL::ThreadSafeCache.new(@failed_cache_size, @failed_cache_ttl) 
    end
  end # def register

  public
  def filter(event)
    ip = event.get(@source)
    if ip.nil? or ip.empty?
      @tag_on_failure.each{|tag| event.tag(tag)}
      return
    end

    begin
      return if @failed_cache && @failed_cache[ip]

      result = nil
      if @hit_cache
        result = @hit_cache[ip]
        if result.nil?
          result = filter_ex(ip)
          if !result.nil?
            @hit_cache[ip] = result
          end
        end
      else
        result = filter_ex(ip)
      end

      if result.nil?
        @tag_on_failure.each{|tag| event.tag(tag)}
        @logger.warn("IP result is null", :ip => ip)
        return
      end

      result.each do |k, v|
        event.set(k, v)
      end
    rescue => e
      @logger.warn('IP filter failed', :message => e.message, :stack => e.backtrace.join("\n"))
      @tag_on_failure.each{|tag| event.tag(tag)}
    end 

  end

  private
  def filter_ex(ip)
    begin
      result = {}
      ip_num, ip_str = ip_convert(ip)
      result[@inner_name] = is_inner_ip(ip_num)
      result["#{@source}_str"] = ip_str

      return result
    rescue => e
      @logger.warn(e.message)
      @logger.warn('IP convert error:', :message => e.message, :stack => e.backtrace.join("\n"))
      return nil
    end
  end

  private 
  def is_inner_ip(ip_num)
    @inner_ip_list.each do |item|
      if ip_num >= item[0] and ip_num <= item[1]
        return true
      end
    end

    return false
  end

  private
  def ip_convert(ip)
    begin
      ip_obj = IPAddr.new ip
      return [ip_obj.to_i, ip_obj.to_s]
    rescue => e
      puts("IP address parse failed. IP: #{ip}, Message: #{e.message}")
      return [-1, ip]
    end
  end

end # class LogStash::Filters::Ip

