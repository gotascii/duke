require 'spec_helper'

describe Controller do
  before do
    Duke::Config.stub(:log_dir).and_return("log_dir")
    Duke::Config.stub(:pid_dir).and_return("pid_dir")
    @controller = Controller.new('repo_dir', 4567)
    @dir = Dir.pwd
  end

  describe ".pid_files" do
    it "finds a list of all the pid files in the pid dir" do
      Dir.should_receive(:[]).with("pid_dir/*.pid").and_return(['pid_file'])
      Controller.pid_files.should == ['pid_file']
    end
  end

  describe "#initialize(repo_dir, port)" do
    context "with a repo_dir and a port" do
      it "has a dir that matches cwd" do
        @controller.dir.should == @dir
      end

      it "has a repo_dir" do
        @controller.repo_dir.should == 'repo_dir'
      end

      it "has a timeout of 7 seconds" do
        @controller.timeout.should == 7
      end
    end
  end

  describe "#port" do
    context "when a port is provided during initialization" do
      it "is the provided port" do
        @controller.port.should == 4567
      end
    end

    context "when a port is not provided during initialization" do
      it "is the current_port" do
        @controller = Controller.new('repo_dir')
        @controller.stub(:current_port).and_return(1234)
        @controller.port.should == 1234
      end
    end
  end

  describe "#current_port" do
    context "when a cijoe is running for repo_dir" do
      it "determines what port cijoe is running on" do
        Controller.stub(:pid_files).and_return(['repo_dir.1234.pid'])
        @controller.current_port.should == 1234
      end
    end

    context "when a cijoe is not running for repo_dir" do
      it "returns nil" do
        Controller.stub(:pid_files).and_return(['weird_dir.1234.pid'])
        @controller.current_port.should == nil
      end
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
      Duke::Config.stub(:host).and_return("localhost")
      TCPSocket.should_receive(:new).with('localhost', 4567).and_return('sockette!')
      @controller.ping_command.call.should == 'sockette!'
    end
  end

  describe "#running" do
    context "when port is nil" do
      it "is false" do
        @controller.stub(:port).and_return(nil)
        @controller.running?.should be_false
      end
    end

    context "when port is not nil" do
      it "is delegates to controller" do
        controller = double("controller")
        controller.should_receive(:running?).and_return('running?')
        @controller.stub(:controller).and_return(controller)
        @controller.running?.should == "running?"
      end
    end
  end

  describe "#controller" do
    it "instantiates a DaemonController" do
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