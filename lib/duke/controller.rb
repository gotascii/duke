module Duke
  class Controller
    extend Forwardable
    def_delegators :controller, :start, :stop, :running?, :pid
    attr_reader :dir, :repo_dir, :timeout
    attr_accessor :port

    def self.pid_files
      Dir["#{::Duke::Config.pid_dir}/*.pid"]
    end

    def self.port(repo_dir)
      repo_dir_regex = /#{repo_dir}\.(\d+)/
      pid_files.each do |pid_file|
        return $1.to_i if pid_file =~ repo_dir_regex
      end
      nil
    end

    def initialize(repo_dir, port)
      @dir = Dir.pwd
      @repo_dir = repo_dir
      @port = port
      @timeout = 7
    end

    def identifier
      "#{repo_dir}.#{port}"
    end

    def pid_file
      "#{dir}/#{::Duke::Config.pid_dir}/#{identifier}.pid"
    end

    def log_file
      "#{dir}/#{::Duke::Config.log_dir}/#{identifier}.log"
    end

    def ping_command
      lambda { TCPSocket.new(::Duke::Config.host, port) }
    end

    def controller
      @controller ||= DaemonController.new({
        :identifier    => identifier,
        :start_command => "duke cijoed #{repo_dir} #{port} #{log_file} #{pid_file}",
        :ping_command  => ping_command,
        :pid_file      => pid_file,
        :log_file      => log_file,
        :log_file_activity_timeout => timeout,
        :start_timeout => timeout
      })
    end
  end
end