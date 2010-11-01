module Duke
  class Cli < Thor
    include Thor::Actions

    source_root File.join(File.dirname(__FILE__), '..', '..')

    desc "install [DIR]", "install duke into DIR or current directory"
    def install(dir=nil)
      dir ||= "."
      [dir, "#{dir}/tmp", "#{dir}/tmp/pids", "#{dir}/log"].each do |dir_name|
        Dir.mkdir(dir_name) unless Dir.exists?(dir_name)
      end
      directory 'templates', dir
    end

    desc "add REPO_URL", "adds REPO_URL to current duke directory"
    def add(repo_url)
      p = Project.create(repo_url)
      puts "\n\n*** #{p.repo_dir} has been cloned and configured!"
      puts "*** Next steps probably include:"
      puts "*** set up #{p.repo_dir}/config/database.yml"
      puts "*** create the project gemset"
      puts "*** run bundle install"
      puts "*** start up cijoe!"
    end

    desc "start REPO_DIR PORT", "start cijoe for REPO_DIR on PORT"
    def start(repo_dir, port)
      Project.new(repo_dir).start(port)
    end

    desc "stop REPO_DIR", "stop cijoe for REPO_DIR"
    def stop(repo_dir)
      Project.new(repo_dir).stop
    end

    desc "list", "list cijoe server statues"
    def list
      Project.all.each do |p|
        puts "#{p.repo_dir}, #{p.running? ? "running on port #{p.port}" : "stopped"}"
      end
    end

    desc "cijoed", "daemonized cijoe wrapper"
    def cijoed(repo_dir, port, log_file, pid_file)
      exec("nohup cijoe -p #{port} #{repo_dir} 1>#{log_file} 2>&1 & echo $! > #{pid_file}")
    end
  end
end