module Duke
  class Project
    include Thor::Actions

    attr_reader :name

    def self.dirs
      Dir['*'].select do |name|
        new(name).repo?
      end
    end

    def self.all
      dirs.collect{|name| new(name) }
    end

    def self.create(repo_url)
      name = repo_url.slice(/\/(.*).git$/, 1)
      p = new(name)
      p.clone(repo_url)
      p.set_runner ::Duke::Config.runner
      p.set_campfire ::Duke::Config.campfire
      p
    end

    def initialize(name)
      @name = name
    end

    def git_path
      File.join(name, '.git')
    end

    def repo?
      File.exist?(git_path)
    end

    def clone(url)
      run "git clone #{url} #{name}"
    end

    def add_config_to_repo(key, value)
      inside(name) do
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

    # def build
    #   uri = URI.parse("http://#{Config.cijoe_url}/#{name}")
    #   Net::HTTP.post_form(uri, {})
    # end
  end
end