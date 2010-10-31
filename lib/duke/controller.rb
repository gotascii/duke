module Duke
  class Controller
    extend Forwardable
    def_delegators :controller, :start, :stop
    attr_reader :dir, :repo_name, :port, :identifier,
      :pid_file, :log_file, :ping_command, :timeout

    def initialize(repo_name, port)
      @dir = Dir.pwd
      @repo_name = repo_name
      @port = port
      @identifier = "#{repo_name}.#{port}"
      @pid_file = "#{dir}/tmp/pids/#{identifier}.pid"
      @log_file = "#{dir}/log/#{identifier}.log"
      @ping_command = lambda { TCPSocket.new('localhost', port) }
      @timeout = 7
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