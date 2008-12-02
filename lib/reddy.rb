#$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$:.unshift(File.dirname('reddy'))
Dir.glob(File.join(File.dirname(__FILE__), 'reddy/**.rb')).each { |f| require f }

module Reddy
  VERSION = '0.0.2'
end
