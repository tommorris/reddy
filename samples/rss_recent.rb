#!/usr/bin/env ruby

# Modifyied from RSS Parser.

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")

require 'open-uri'
require 'time'
require 'rena'

require 'rena/rdf'
require 'rena/rss'
require 'rena/dc'
RDF = Rena::RDF
RSS = Rena::RSS
DC  = Rena::DC


class Time
	class << self
		unless respond_to?(:w3cdtf)
			def w3cdtf(date)
				if /\A\s*
				    (-?\d+)-(\d\d)-(\d\d)
				    (?:T
				    (\d\d):(\d\d)(?::(\d\d))?
				    (\.\d+)?
				    (Z|[+-]\d\d:\d\d)?)?
				    \s*\z/ix =~ date and (($5 and $8) or (!$5 and !$8))
					datetime = [$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i] 
					datetime << $7.to_f * 1000000 if $7
					if $8
						Time.utc(*datetime) - zone_offset($8)
					else
						Time.local(*datetime)
					end
				else
					raise ArgumentError.new("invalid date: #{date.inspect}")
				end
			end
		end
	end

	unless instance_methods.include?("w3cdtf")
		alias w3cdtf iso8601
	end
end



items = []
verbose = false

def error(exception)
	mark = "=" * 20
	mark = "#{mark} error #{mark}"
	puts mark
	puts exception.class
	puts exception.message
	puts exception.backtrace
	puts mark
end


ARGV.each do |fname|
  if fname == '-v'
    verbose = true
    next
  end
  
  model = Rena::MemModel.new
  begin
    model.load(fname, :content_type => "application/rdf+xml")
  rescue Rena::LoadError => e
    error(e) if verbose
  end
  
  rss_channel = model.lookup_resource(RSS::Channel)
  model.each_resource{|channel|
    next unless channel.have_property?(RDF::Type, rss_channel)

    (channel.get_property(RSS::Items) || []).each_property{|prop,item|
      next unless %r!\Ahttp://www.w3.org/1999/02/22-rdf-syntax-ns#_(\d+)\Z! =~ prop.to_s

      begin    
        items << [Time.w3cdtf(item.get_property(DC::Date))
                  channel, item]
      rescue ArgumentError
      end
    }
  }
end
processing_time = Time.now - before_time

items.sort{|x,y| y[0] <=> x[0] }[0..20].each{
  |dc_date, channel, item|

  channel_title    = channel.get_property(RSS::Title)
  item_title       = item.get_property(RSS::Title)
  item_description = item.get_property(RSS::Description)

  puts "#{dc_date.localtime.w3cdtf}: " <<
    "#{channel_title}: #{item_title}"
  puts " Description: #{item_description}" if item_description
}
