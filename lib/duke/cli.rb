module Duke
  class Cli < Thor
    desc "install [DIR]", "sets up DIR or current directory to run multiple cijoes"
    def install(dir=nil)
      dir ||= "."
      [dir, "#{dir}/tmp", "#{tmp_dir}/pids", "#{dir}/log"].each do |dir_name|
        Dir.mkdir(dir_name) unless Dir.exists?(dir_name)
      end
      directory 'templates', dir
    end

    desc "add REPO_URL", "adds project at REPO_URL"
    def add(repo_url)
      p = Project.create(repo_url)
      puts "\n\n*** #{p.name} has been cloned and configured!"
      puts "*** Next steps probably include:"
      puts "*** set up #{p.name}/config/database.yml"
      puts "*** create the project gemset"
      puts "*** run bundle install"
      puts "*** start up cijoe!"
    end

    desc "start REPO_NAME PORT", "start cijoe for REPO_NAME on PORT"
    def start(repo_name, port)
      Project.new(repo_name).start(port)
    end

    desc "stop REPO_NAME", "stop cijoe for REPO_NAME running on port PORT"
    def stop(repo_name)
      Project.new(repo_name).stop
    end

    desc "list", "list added projects and server status"
    def list
      Project.all.each do |p|
        puts "#{p.name}, #{p.running? ? "running" : "stopped"}"
      end
    end

    desc "cijoed", "daemonized cijoe wrapper"
    def cijoed(repo_name, port, log_file, pid_file)
      exec("nohup cijoe -p #{port} #{repo_name} 1>#{log_file} 2>&1 & echo $! > #{pid_file}")
    end
  end
end