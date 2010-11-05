module Duke
  class Project < Thor::Group
    include Thor::Actions
    extend Forwardable
    def_delegators :controller, :stop, :pid, :running?
    attr_reader :repo_dir, :repo_url

    def self.all
      Dir['*'].collect do |repo_dir|
        find(:repo_dir => repo_dir)
      end.compact
    end

    def self.create(repo_url)
      p = new(repo_url)
      p.clone
      p.set_runner Config.runner
      p.set_campfire Config.campfire
      p
    end

    def self.find(opts)
      p = new(opts)
      p if p.repo_dir?
    end

    def initialize(opts)
      args = []
      options = {}
      config = {}
      super
      @repo_url = opts[:repo_url] if opts[:repo_url]
      @repo_dir = opts[:repo_dir] || opts[:repo_url].repo_dir
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
      msg = if running?
        "port #{port}, pid #{pid}, #{pass? ? 'passing' : 'building or broken' }"
      else
        "stopped"
      end
      puts "#{repo_dir}, #{msg}"
    end

    def build
      uri = URI.parse("http://#{Config.host}:#{port}")
      Net::HTTP.post_form(uri, {})
    end

    def ping
      Net::HTTP.start('localhost', 4567) {|http| http.get("/ping") }
    end

    def pass?
      ping.code == 200
    end
  end
end