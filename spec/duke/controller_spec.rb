describe "An instance of Controller" do
  before do
    @repo_name = 'repo'
    @port = 4567
    @controller = Duke::Controller.new(@repo_name, @port)
    @dir = Dir.pwd
  end

  it "has a dir that matches cwd" do
    @controller.dir.should == @dir
  end

  it "has a repo_name" do
    @controller.repo_name.should == @repo_name
  end

  it "has a port" do
    @controller.port.should == @port
  end

  it "has an identifier made up of repo_name and port" do
    @controller.identifier.should == "repo.4567"
  end

  it "has a pid_file" do
    @controller.pid_file.should == "#{@dir}/tmp/pids/repo.4567.pid"
  end

  it "has a log_file" do
    @controller.log_file.should == "#{@dir}/log/repo.4567.log"
  end

  it "has a ping command" do
    TCPSocket.should_receive(:new).with('localhost', 4567).and_return('sockette!')
    @controller.ping_command.call.should == 'sockette!'
  end

  it "has a timeout of 7 seconds" do
    @controller.timeout.should == 7
  end

  it "has a DaemonController instance" do
    @controller.stub(:identifier).and_return("identifier!")
    @controller.stub(:ping_command).and_return("ping_command!")
    @controller.stub(:pid_file).and_return("pid_file!")
    @controller.stub(:log_file).and_return("log_file!")
    args = {
      :identifier    => "identifier!",
      :start_command => "cijoed identifier!",
      :ping_command  => "ping_command!",
      :pid_file      => "pid_file!",
      :log_file      => "log_file!",
      :log_file_activity_timeout => 7,
      :start_timeout => 7
    }
    DaemonController.should_receive(:new).with(args).and_return("controller!")
    @controller.controller.should == "controller!"
  end
end