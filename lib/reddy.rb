$:.unshift File.dirname(__FILE__)
Dir.glob(File.join(File.dirname(__FILE__), 'reddy/**.rb')).each { |f| require f }

module Reddy
end
