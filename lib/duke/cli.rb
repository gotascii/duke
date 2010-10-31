module Duke
  class Cli < Thor
    desc "start REPO_NAME PORT", "start cijoe for REPO_NAME on PORT"
    def start(repo_name, port)
      Controller.new(repo_name, port).start
    end

    desc "stop REPO_NAME PORT", "stop cijoe for REPO_NAME running on port PORT"
    def stop(repo_name, port)
      Controller.new(repo_name, port).stop
    end

    desc "cijoed", "daemonized cijoe wrapper"
    def cijoed(repo_name, port, log_file, pid_file)
      exec("nohup cijoe -p #{port} #{repo_name} 1>#{log_file} 2>&1 & echo $! > #{pid_file}")
    end
  end
end