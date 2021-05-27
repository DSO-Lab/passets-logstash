# encoding: utf-8
require "logstash/filters/base"

require 'ipaddr'
require "json"

class Reader
  def initialize(name)

    if name.nil? || !File.exists?(name)
      raise "You must specify 'database => ...' in your ipip filter (I looked for '#{name}')"
    end
    if !File.readable? name
      raise "ip database is not readable."
    end

    @data = File.binread name

    meta_len = @data[0 ... 4].unpack('N')[0]
    meta_buf = @data[4 ... 4+meta_len]

    @meta = JSON.parse(meta_buf)

    if @data.length != (4 + meta_len + @meta['total_size'])
        raise "ip database file size error."
    end

    @node_count = @meta['node_count']
    @cache = {}
    @body = @data[4+meta_len ... @data.length]
  end

  def read_node(node, idx)
    off = node * 8 + idx * 4
    @body[off..off+3].unpack('N')[0]
  end


  def find_node(ipv)
    addr = ipv.hton
    node = ipv.ipv4? ? 96 : 0

    idx = 0
    key = addr[0...16]
    val = @cache[key]
    if !val.nil?
      node = val
      idx = 16
    end

    if node < @node_count
      while idx < 128 do
        bin = addr[idx >> 3].unpack("C")[0]
        flag = (1 & (bin >> 7 - (idx % 8)))
        node = self.read_node(node, flag)
        idx += 1
        if idx == 16
          @cache[key] = node
        end
        if node > @node_count
          break
        end
      end
    end

    node
  end

  def find(ipx,lang)
    begin
        ipv = IPAddr.new ipx
    rescue => e
      return e.message
    end
    node = self.find_node ipv
    resolved = node - @node_count + @node_count * 8
    size = @body[resolved..resolved+1].unpack('n')[0]

    temp = @body[resolved+2..resolved+1+size]
    loc = temp.encode("UTF-8", "UTF-8").split("\t", @meta['fields'].length * @meta['languages'].length)

    off = @meta['languages'][lang]

    loc = loc[off ... @meta['fields'].length+off]

    if loc.length <= 5
     return {
          country_name: loc[0],
          city_name: loc[2]
      }
    else
      return {
          country_name: loc[0],
          city_name: loc[2],
          location:{
            lat: loc[5],
            lon: loc[6]
          }
      }
    end
  end
end

# This  filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::Ipip < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #    {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "ipip"

  # Replace the message with this value.
  config :source, :validate => :string, :required => true
  config :database, :validate => :path, :required => true
  config :target, :validate => :string, :default => "ipip"
  config :language, :validate => :string, :default => "CN"


  public
  def register
    # Add instance variables
    #
    
    @reader = Reader.new @database
  end # def register

  public
  def filter(event)

    if @source
      # Replace the event message with our message as configured in the
      # config file.
      ipx = event.get(@source)
      loc = @reader.find(ipx, @language)
      event.set(@target, loc)
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Ipip
