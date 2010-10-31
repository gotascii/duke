require 'spec_helper'

describe "An instance of Cli" do
  before do
    @cli = Duke::Cli.new
    @repo_name = "repo"
    @port = 4567
    @cont = double("controller")
  end

  it "creates a new controller with repo_name and port" do
    @cont.stub(:start).and_return(true)
    Duke::Controller.should_receive(:new).with(@repo_name, @port).and_return(@cont)
    @cli.start(@repo_name, @port)
  end

  it "starts the controller" do
    @cont.should_receive(:start)
    Duke::Controller.stub(:new).and_return(@cont)
    @cli.start(@repo_name, @port)
  end

  it "execs the cijoe daemon" do
    @cli.should_receive(:exec).with("nohup cijoe -p 4567 repo 1>log_file! 2>&1 & echo $! > pid_file!")
    @cli.cijoed(@repo_name, @port, 'log_file!', 'pid_file!')
  end
end
