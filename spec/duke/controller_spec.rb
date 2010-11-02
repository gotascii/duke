require 'spec_helper'

describe Controller do
  before do
    ::Duke::Config.stub(:log_dir).and_return("log_dir")
    ::Duke::Config.stub(:pid_dir).and_return("pid_dir")
    @controller = Controller.new('repo_dir', 4567)
    @dir = Dir.pwd
  end

  describe "#initialize(repo_dir, port)" do
    it "has a dir that matches cwd" do
      @controller.dir.should == @dir
    end

    it "has a repo_dir" do
      @controller.repo_dir.should == 'repo_dir'
    end

    it "has a port reader" do
      @controller.port.should == 4567
    end

    it "has a port writer" do
      @controller.port = 1234
      @controller.port.should == 1234
    end

    it "has a timeout of 7 seconds" do
      @controller.timeout.should == 7
    end
  end

  describe "#identifier" do
    it "identifies the controller via repo_dir and port" do
      @controller.identifier.should == "repo_dir.4567"
    end
  end

  describe "#pid_file" do
    it "is the path to the pid file" do
      @controller.pid_file.should == "#{@dir}/pid_dir/repo_dir.4567.pid"
    end
  end

  describe "#log_file" do
    it "is the path to the log file" do
      @controller.log_file.should == "#{@dir}/log_dir/repo_dir.4567.log"
    end
  end

  describe "#ping_command" do
    it "verifies that cijoe is running" do
      TCPSocket.should_receive(:new).with('localhost', 4567).and_return('sockette!')
      @controller.ping_command.call.should == 'sockette!'
    end
  end

  describe "#controller" do
    it "instantiates a DaemonController instance" do
      @controller.stub(:identifier).and_return("identifier")
      @controller.stub(:ping_command).and_return("ping_command")
      @controller.stub(:pid_file).and_return("pid_file")
      @controller.stub(:log_file).and_return("log_file")
      args = {
        :identifier    => "identifier",
        :start_command => "duke cijoed repo_dir 4567 log_file pid_file",
        :ping_command  => "ping_command",
        :pid_file      => "pid_file",
        :log_file      => "log_file",
        :log_file_activity_timeout => 7,
        :start_timeout => 7
      }
      DaemonController.should_receive(:new).with(args).and_return("controller")
      @controller.controller.should == "controller"
    end
  end
end