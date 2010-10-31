$LOAD_PATH << File.dirname(__FILE__)

require 'forwardable'
require 'daemon_controller'
require 'thor'
require 'socket'
require 'duke/controller'
require 'duke/cli'