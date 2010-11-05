require '../lib/duke'

Duke::App.configure do |config|
  config.set :app_file, __FILE__
  config.set :show_exceptions, true
end

run Duke::App