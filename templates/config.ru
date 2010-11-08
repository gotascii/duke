require 'duke'

Duke::App.configure do |config|
  config.set :app_file, __FILE__
  config.set :show_exceptions, true
  config.set :method_override, true
end

run Duke::App