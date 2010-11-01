$LOAD_PATH << File.dirname(__FILE__)

require 'forwardable'
require 'daemon_controller'
require 'thor'
require 'socket'
require 'sinatra/base'
require 'duke/controller'
require 'duke/cli'
require 'duke/project'
require 'duke/app'

module Duke
  CONFIG_DEFAULT = {
    :runner => 'rake cruise',
    :campfire => {}
  }
  config_path = File.join('config', 'config.yml')
  config_yml = File.exist?(config_path) ? YAML.load_file(config_path) : {}
  config = CONFIG_DEFAULT.merge(config_yml)
  Config = OpenStruct.new(config)
end