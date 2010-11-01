module Duke
  class Controller
    extend Forwardable
    def_delegators :controller, :start, :stop, :running?
    attr_reader :dir, :repo_name, :port, :timeout

    def initialize(repo_name, port)
      @dir = Dir.pwd
      @repo_name = repo_name
      @port = port
      @timeout = 7
    end

    def identifier
      "#{repo_name}.#{port}"
    end

    def pid_file
      "#{dir}/tmp/pids/#{identifier}.pid"
    end

    def log_file
      "#{dir}/log/#{identifier}.log"
    end

    def ping_command
      lambda { TCPSocket.new('localhost', port) }
    end

    def controller
      @controller ||= DaemonController.new({
        :identifier    => identifier,
        :start_command => "duke cijoed #{repo_name} #{port} #{log_file} #{pid_file}",
        :ping_command  => ping_command,
        :pid_file      => pid_file,
        :log_file      => log_file,
        :log_file_activity_timeout => timeout,
        :start_timeout => timeout
      })
    end
  end
end