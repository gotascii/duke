require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "duke"
    gem.summary = %Q{Manage your CIJoes.}
    gem.description = %Q{Allows you to easily manage multiple CIJoes.}
    gem.email = "gotascii@gmail.com"
    gem.homepage = "http://github.com/gotascii/duke"
    gem.authors = ["Justin Marney"]
    gem.add_runtime_dependency "thor"
    gem.add_runtime_dependency "cijoe"
    gem.add_runtime_dependency "daemon_controller"
    gem.add_development_dependency "rspec", ">= 2.0.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

desc "run for cover"
task :simplecov do
  ENV['SIMPLECOV'] = 'true'
  Rake::Task[:spec].invoke
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "duke #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
