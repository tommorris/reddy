$:.unshift File.dirname(__FILE__)
Dir.glob(File.join(File.dirname(__FILE__), 'rena/*.rb')).each { |f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'exceptions/*.rb')).each { |f| require f }

module Rena
end