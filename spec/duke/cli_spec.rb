require 'spec_helper'

describe Cli do
  before do
    @cli = Cli.new
  end

  describe "#new" do
    before do
      Duke::Config.stub(:log_dir).and_return("log_dir")
      Duke::Config.stub(:pid_dir).and_return("pid_dir")
      FileUtils.stub(:mkdir_p)
      FileUtils.stub(:mkdir_p)
      @cli.stub(:directory)
    end

    context "with no argument" do
      it "creates the config'd pid directory in the current directory" do
        FileUtils.should_receive(:mkdir_p).with("./pid_dir")
        @cli.new
      end

      it "creates the config'd log directory in the current directory" do
        FileUtils.should_receive(:mkdir_p).with("./log_dir")
        @cli.new
      end

      it "copies templates into the current directory" do
        @cli.should_receive(:directory).with('templates', '.')
        @cli.new
      end
    end

    context "with a path argument" do
      it "creates the config'd pid directory in the path" do
        FileUtils.should_receive(:mkdir_p).with("/path/pid_dir")
        @cli.new('/path')
      end

      it "creates the config'd log directory in the path" do
        FileUtils.should_receive(:mkdir_p).with("/path/log_dir")
        @cli.new('/path')
      end

      it "copies templates into the path" do
        @cli.should_receive(:directory).with('templates', '/path')
        @cli.new('/path')
      end
    end
  end

  describe "#add(repo_url)" do
    it "creates a Project with repo_url" do
      project = double("project", :repo_dir => 'repo_dir')
      Project.should_receive(:create).with(:repo_url => "repo_url").and_return(project)
      @cli.stub(:puts)
      @cli.add("repo_url")
    end
  end

  describe "#start(repo_dir, port)" do
    before do
      @project = double("project")
    end

    it "instantiates the Project with repo_dir" do
      @project.stub(:start)
      Project.should_receive(:find).with(:repo_dir => 'repo_dir').and_return(@project)
      @cli.start('repo_dir', 4567)
    end

    it "starts the Project on the specified port" do
      @project.should_receive(:start).with(4567)
      Project.stub(:find).and_return(@project)
      @cli.start('repo_dir', 4567)
    end
  end

  describe "#stop(repo_dir)" do
    before do
      @project = double("project")
    end

    it "instantiates the Project with repo_dir" do
      @project.stub(:stop)
      Project.should_receive(:find).with(:repo_dir => 'repo_dir').and_return(@project)
      @cli.stop('repo_dir')
    end

    it "stops the Project in repo_dir" do
      @project.should_receive(:stop)
      Project.stub(:find).and_return(@project)
      @cli.stop('repo_dir')
    end
  end

  describe "#list" do
    it "calls print_status_msg on each Project" do
      project = double("project")
      project.should_receive(:print_status_msg)
      Project.stub(:all).and_return([project])
      @cli.list
    end
  end

  describe "#cijoed(repo_dir, port, log_file, pid_file)" do
    it "runs cijoe daemon in repo_dir on port using log_file and pid_file" do
      @cli.should_receive(:exec).with("nohup cijoe -p 4567 repo_name 1>log_file 2>&1 & echo $! > pid_file")
      @cli.cijoed('repo_name', 4567, 'log_file', 'pid_file')
    end
  end

  describe "#build(repo_dir)" do
    before do
      @project = double("project")
    end

    it "instantiates the Project with repo_dir" do
      @project.stub(:build)
      Project.should_receive(:find).with(:repo_dir => 'repo_dir').and_return(@project)
      @cli.build('repo_dir')
    end

    it "builds the Project in repo_dir" do
      @project.should_receive(:build)
      Project.stub(:find).and_return(@project)
      @cli.build('repo_dir')
    end
  end

  describe "#runner(repo_dir, cmd)" do
    before do
      @project = double("project")
    end

    it "finds the Project with repo_dir" do
      @project.stub(:set_runner)
      Project.should_receive(:find).with(:repo_dir => 'repo_dir').and_return(@project)
      @cli.runner('repo_dir', 'cmd')
    end

    it "sets the Project runner to cmd" do
      @project.should_receive(:set_runner).with('cmd')
      Project.stub(:find).and_return(@project)
      @cli.runner('repo_dir', 'cmd')
    end
  end
end
