$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'

unless ENV['SIMPLECOV'].nil?
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'duke'
include Duke

Rspec.configure do |c|
  c.mock_with :rspec
end
