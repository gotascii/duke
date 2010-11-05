module Duke
  class Project < Thor::Group
    include Thor::Actions
    extend Forwardable
    def_delegators :controller, :stop, :pid, :running?
    attr_reader :repo_dir, :repo_url

    def self.all
      Dir['*'].collect do |repo_dir|
        find(repo_dir)
      end.compact
    end

    def self.create(repo_url)
      p = new(repo_url)
      p.clone
      p.set_runner Config.runner
      p.set_campfire Config.campfire
      p
    end

    def self.find(repo_id)
      p = new(repo_id)
      p if p.repo_dir?
    end

    def initialize(repo_id)
      args = []
      options = {}
      config = {}
      super
      @repo_url = repo_id if repo_id.repo_url?
      @repo_dir = repo_id.repo_dir
    end

    def controller
      @controller ||= Controller.new(repo_dir, port)
    end

    def start(port)
      controller.port = port
      controller.start
    end

    def port
      Controller.port(repo_dir)
    end

    def git_dir
      File.join(repo_dir, '.git')
    end

    def repo_dir?
      File.exist?(git_dir)
    end

    def clone
      run "git clone #{repo_url}"
    end

    def add_config_to_repo(key, value)
      inside(repo_dir) do
        run "git config --add \"#{key}\" \"#{value}\""
      end
    end

    def set_runner(runner)
      add_config_to_repo("cijoe.runner", runner)
    end

    def set_campfire(campfire)
      campfire.each do |k, v|
        add_config_to_repo("campfire.#{k}", v)
      end
    end

    def print_status_msg
      puts "#{repo_dir}, #{running? ? "running on port #{port} with pid #{pid}" : "stopped"}"
    end

    def build
      uri = URI.parse("http://#{Config.host}:#{port}")
      Net::HTTP.post_form(uri, {})
    end
  end
end