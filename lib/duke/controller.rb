module Duke
  class Controller
    def initialize(repo_name, port)
      @dir = Dir.pwd
      @repo_name = repo_name
      @port = port
      @identifier = "#{repo_name}.#{port}"
      @pid_file = "#{@dir}/tmp/pids/#{identifier}.pid"
      @log_file = "#{@dir}/log/#{identifier}.log"
      @controller = DaemonController.new({
        :identifier    => "cijoe server for #{repo_name} on port #{port}",
        :start_command => "cijoed #{@identifier}",
        :ping_command  => lambda { TCPSocket.new('localhost', port) },
        :pid_file      => @pid_file,
        :log_file      => @log_file,
        :log_file_activity_timeout => 120,
        :start_timeout => 120
      })
    end

    def start
      @controller.start
    end

    def stop
      @controller.stop
    end
  end
end