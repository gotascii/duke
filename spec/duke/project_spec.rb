require 'spec_helper'

describe Project do
  before do
    @project = Project.new(:repo_dir => 'repo_dir')
  end

  describe ".all" do
    context "without a repo_dir in the current directory" do
      it "does not contain a Project instance" do
        Dir.stub(:[]).with('*').and_return(['non_repo'])
        project = double("project", :repo_dir? => false)
        Project.stub(:new).with(:repo_dir => 'non_repo').and_return(project)
        Project.all.should be_empty
      end
    end
  
    context "with a repo_dir in the current directory" do
      it "contains the Project instance for repo_dir" do
        Dir.stub(:[]).with('*').and_return(['repo_dir'])
        project = double("project", :repo_dir? => true)
        Project.stub(:new).with(:repo_dir => 'repo_dir').and_return(project)
        Project.all.should == [project]
      end
    end
  end
  
  describe ".create" do
    before do
      @project = double("project", :clone => nil, :set_runner => nil, :set_campfire => nil)
      Project.stub(:new).with(:repo_url => 'repo_url').and_return(@project)
    end
  
    it "instantiates a Project with repo_url" do
      Project.create(:repo_url => 'repo_url').should == @project
    end
  
    it "clones the Project instance" do
      @project.should_receive(:clone)
      Project.create(:repo_url => 'repo_url')
    end
  
    it "sets the Project instance runner command from config" do
      Duke::Config.stub(:runner).and_return('runner')
      @project.should_receive(:set_runner).with('runner')
      Project.create(:repo_url => 'repo_url')
    end
  
    it "sets the Project instance campfire from config" do
      Duke::Config.stub(:campfire).and_return('campfire')
      @project.should_receive(:set_campfire).with('campfire')
      Project.create(:repo_url => 'repo_url')
    end
  end

  describe "#initialize(opts)" do
    context "when opts contains a repo_url" do
      before do
        repo_url = 'repo_url'
        repo_url.stub(:repo_dir).and_return('repo_dir')
        @project = Project.new(:repo_url => repo_url)
      end

      it "has a repo_url" do
        @project.repo_url.should == 'repo_url'
      end

      it "has a repo_dir" do
        @project.repo_dir.should == 'repo_dir'
      end
    end

    context "when opts contains a repo_dir" do
      it "does not have a repo_url" do
        @project.repo_url.should be_nil
      end
    
      it "has a repo_dir" do
        @project.repo_dir.should == 'repo_dir'
      end
    end
  end

  describe "#controller" do
    it "instantiates a Controller with repo_dir" do
      Controller.stub(:new).with('repo_dir').and_return('controller')
      @project.controller.should == 'controller'
    end
  end

  describe "#start(port)" do
    before do
      @controller = double("controller")
    end
  
    it "instantiates a Controller with repo_dir and port" do
      @controller.stub(:start)
      Controller.should_receive(:new).with('repo_dir', 4567).and_return(@controller)
      @project.start(4567)
      @project.controller.should == @controller
    end

    it "starts the new controller" do
      @controller.should_receive(:start)
      Controller.stub(:new).and_return(@controller)
      @project.start(4567)
    end
  end
  
  describe "#git_dir" do
    it "is the path to the git config dir" do
      @project.git_dir.should == "repo_dir/.git"
    end
  end
  
  describe "#repo_dir?" do
    it "determines if repo_dir is an actual git repo" do
      @project.stub(:git_dir).and_return('git_dir')
      File.should_receive(:exist?).with('git_dir').and_return(true)
      @project.repo_dir?.should == true
    end
  end
  
  describe "#clone" do
    it "clones the repo_url" do
      project = Project.new(:repo_url => 'repo_url')
      project.should_receive(:run).with("git clone repo_url")
      project.clone
    end
  end
  
  describe "#add_config_to_repo(key, value)" do
    it "adds a key value pair to the git config" do
      @project.stub(:inside).with('repo_dir').and_yield
      @project.should_receive(:run).with("git config --add \"key\" \"value\"")
      @project.add_config_to_repo('key', 'value')
    end
  end
  
  describe "#set_runner" do
    it "sets the runner git config entry" do
      @project.should_receive(:add_config_to_repo).with("cijoe.runner", 'runner')
      @project.set_runner('runner')
    end
  end
  
  describe "#set_campfire" do
    it "sets campfire values in the git config" do
      @project.should_receive(:add_config_to_repo).with("campfire.camp", 'fire')
      @project.should_receive(:add_config_to_repo).with("campfire.fire", 'camp')
      @project.set_campfire({:camp => 'fire', :fire => 'camp'})
    end
  end

  # describe "#print_status_msg" do
  #   context "when cijoe is not running" do
  #     it "puts the repo_dir and indicates cijoe is stopped" do
  #       @project.stub(:running?).and_return(false)
  #       @project.should_receive(:puts).with("repo_dir, stopped")
  #       @project.print_status_msg
  #     end
  #   end
  # 
  #   context "when cijoe is running" do
  #     it "puts the repo_dir, and indicates the port and pid of cijoe" do
  #       @project.stub(:running?).and_return(true)
  #       @project.stub(:port).and_return(4567)
  #       @project.stub(:pid).and_return(666)
  #       @project.should_receive(:puts).with("repo_dir, port 4567, pid 666, building or broken")
  #       @project.print_status_msg
  #     end
  #   end
  # end
  
  describe "#build" do
    it "sends a POST to cijoe in order to start a build" do
      Duke::Config.stub(:host).and_return('localhost')
      URI.stub(:parse).with("http://localhost:4567").and_return('uri')
      Net::HTTP.should_receive(:post_form).with('uri', {})
      @project.stub(:port).and_return(4567)
      @project.build
    end
  end
  
  describe "#find" do
    context "searching for a project that exists" do
      it "instantiates a Project for the given repo_dir" do
        project = double("project", :repo_dir? => true)
        Project.should_receive(:new).with(:repo_dir => 'repo_dir').and_return(project)
        Project.find(:repo_dir => 'repo_dir').should == project
      end
    end
  end

  describe "#cijoe" do
    context "when project has a repo_dir?" do
      it "instantiates a CIJoe with repo_dir" do
        @project.stub(:repo_dir?).and_return(true)
        cijoe = double("cijoe", :restore => nil)
        CIJoe.should_receive(:new).with('repo_dir').and_return(cijoe)
        @project.cijoe.should == cijoe
      end
    end

    context "when project does not have a repo_dir?" do
      it "returns nil" do
        @project.stub(:repo_dir?).and_return(false)
        @project.cijoe.should be_nil
      end
    end
  end

  describe "#built?" do
    context "when cijoe.last_build is nil" do
      it "is false" do
        @project.stub(:cijoe).and_return(double("cijoe", :last_build => nil))
        @project.built?.should be_false
      end
    end

    context "when cijoe.last_build is not nil" do
      it "is true" do
        @project.stub(:cijoe).and_return(double("cijoe", :last_build => true))
        @project.built?.should be_true
      end
    end
  end

  describe "#passing?" do
    context "when cijoe.last_build.failed? is true" do
      it "is false" do
        last_build = double("last_build", :failed? => true)
        cijoe = double("cijoe", :last_build => last_build)
        @project.stub(:cijoe).and_return(cijoe)
        @project.passing?.should be_false
      end
    end

    context "when cijoe.last_build.failed? is false" do
      it "is true" do
        last_build = double("last_build", :failed? => false)
        cijoe = double("cijoe", :last_build => last_build)
        @project.stub(:cijoe).and_return(cijoe)
        @project.passing?.should be_true
      end
    end
  end
  
  describe "#url" do
    it "contains the configured host along with the cijoe port" do
      @project.stub(:port).and_return(4567)
      Duke::Config.stub(:host).and_return('localhost')
      @project.url.should == 'http://localhost:4567'
    end
  end
end