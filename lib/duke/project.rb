module Duke
  class Project < Thor::Group
    include Thor::Actions
    extend Forwardable
    def_delegators :controller, :stop, :pid, :running?, :port
    def_delegators :cijoe, :building?
    attr_reader :repo_dir, :repo_url
    attr_writer :controller

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

    def cijoe
      @cijoe ||= begin
        ci = CIJoe.new(repo_dir)
        ci.restore
        ci
      end if repo_dir?
    end

    def controller
      @controller ||= Controller.new(repo_dir)
    end

    def start(port)
      self.controller = Controller.new(repo_dir, port)
      controller.start
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
      fields = []
      fields << repo_dir
      if running?
        fields += ["port #{port}", "pid #{pid}"]
        if building?
          fields << 'building...'
        elsif built?
          fields << if passing?
            "passing"
          else
            "failing"
          end
        end
      else
        fields << "stopped"
      end
      puts fields.join(", ")
    end

    def build
      uri = URI.parse(url)
      Net::HTTP.post_form(uri, {})
    end

    def built?
      !cijoe.last_build.nil?
    end

    def passing?
      !cijoe.last_build.failed?
    end

    def url
      "http://#{Config.host}:#{port}"
    end
  end
end