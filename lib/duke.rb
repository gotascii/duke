$LOAD_PATH << File.dirname(__FILE__)

require 'forwardable'
require 'erb'
require 'net/http'
require 'daemon_controller'
require 'fileutils'
require 'thor'
require 'thor/group'
require 'socket'
require 'cijoe'
require 'sinatra/base'
require 'ext/string'
require 'duke/controller'
require 'duke/cli'
require 'duke/project'
require 'duke/app'

module Duke
  CONFIG_DEFAULT = {
    :host => "localhost",
    :runner => "rake",
    :pid_dir => "tmp/pids",
    :log_dir => "log",
    :campfire => {}
  }
  config_path = File.join('config', 'duke.yml')
  config_yml = File.exist?(config_path) ? YAML.load_file(config_path) : {}
  config = CONFIG_DEFAULT.merge(config_yml)
  Config = OpenStruct.new(config)
end