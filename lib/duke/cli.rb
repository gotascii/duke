module Duke
  class Cli < Thor::Group
    include Thor::Actions

    source_root File.join(File.dirname(__FILE__), '..', '..')

    def new(dir=nil)
      dir ||= "."
      [:pid_dir, :log_dir].collect do |meth|
        FileUtils.mkdir_p("#{dir}/#{::Duke::Config.send(meth)}")
      end
      directory 'templates', dir
    end

    def add(repo_url)
      p = Project.create(repo_url)
      puts <<-MSG
*** #{p.repo_dir} has been cloned and configured!
*** Don't forget to:
*** set up #{p.repo_dir}/config/database.yml
*** create the project gemset
*** run bundle install
*** start up cijoe!
MSG
    end

    def start(repo_dir, port)
      Project.new(repo_dir).start(port)
    end

    def stop(repo_dir)
      Project.new(repo_dir).stop
    end

    def list
      Project.all.each(&:print_status_msg)
    end

    def cijoed(repo_dir, port, log_file, pid_file)
      exec("nohup cijoe -p #{port} #{repo_dir} 1>#{log_file} 2>&1 & echo $! > #{pid_file}")
    end
  end
end