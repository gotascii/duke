require 'spec_helper'

describe Project do
  describe ".all" do
    context "without a repo_dir in the current directory" do
      it "does not contain a Project instance" do
        Dir.stub(:[]).with('*').and_return(['non_repo_dir'])
        project = double("project", :repo_dir? => false)
        Project.stub(:new).with('non_repo_dir').and_return(project)
        Project.all.should be_empty
      end
    end

    context "with a repo_dir in the current directory" do
      it "contains the Project instance for repo_dir" do
        Dir.stub(:[]).with('*').and_return(['repo_dir'])
        project = double("project", :repo_dir? => true)
        Project.stub(:new).with('repo_dir').and_return(project)
        Project.all.should == [project]
      end
    end
  end

  describe ".create" do
    before do
      @project = double("project", :clone => nil, :set_runner => nil, :set_campfire => nil)
      Project.stub(:new).and_return(@project)
    end

    it "instantiates a new Project instance with repo_url" do
      Project.create('repo_url').should == @project
    end

    it "clones the Project instance" do
      @project.should_receive(:clone)
      Project.create('repo_url')
    end

    it "sets the Project instance runner command from config" do
      ::Duke::Config.stub(:runner).and_return('runner')
      @project.should_receive(:set_runner).with('runner')
      Project.create('repo_url')
    end

    it "sets the Project instance campfire from config" do
      ::Duke::Config.stub(:campfire).and_return('campfire')
      @project.should_receive(:set_campfire).with('campfire')
      Project.create('repo_url')
    end
  end

  describe "#initialize(repo_id)" do
    context "when repo_id is a repo_url" do
      before do
        @repo_url = 'repo_url'
        @repo_url.stub(:repo_url?).and_return(true)
        @repo_url.stub(:repo_dir).and_return('repo_dir')
        @project = Project.new(@repo_url)
      end

      it "has a repo_url" do
        @project.repo_url.should == 'repo_url'
      end

      it "has a repo_dir" do
        @project.repo_dir.should == 'repo_dir'
      end
    end

    context "when repo_id is a repo_dir" do
      before do
        @repo_dir = 'repo_dir'
        @repo_dir.stub(:repo_url?).and_return(false)
        @repo_dir.stub(:repo_dir).and_return('repo_dir')
        @project = Project.new(@repo_dir)
      end

      it "does not have a repo_url" do
        @project.repo_url.should be_nil
      end

      it "has a repo_dir" do
        @project.repo_dir.should == 'repo_dir'
      end
    end
  end

  describe "#controller" do
    it "instantiates a Controller instance with repo_dir and port" do
      project = Project.new('repo_dir')
      project.stub(:port).and_return(4567)
      Controller.stub(:new).with('repo_dir', 4567).and_return('controller')
      project.controller.should == 'controller'
    end
  end

  describe "#start(port)" do
    before do
      @controller = double("controller", :port= => nil, :start => nil)
      @project = Project.new('repo_id')
      @project.stub(:controller).and_return(@controller)
    end

    it "sets the controller port" do
      @controller.should_receive(:port=).with(4567)
      @project.start(4567)
    end

    it "starts the controller" do
      @controller.should_receive(:start)
      @project.start(4567)
    end
  end

  describe "#git_dir" do
    it "is the path to the git config dir" do
      project = Project.new('repo_dir')
      project.git_dir.should == "repo_dir/.git"
    end
  end

  describe "#repo_dir?" do
    it "determines if repo_dir is an actual git repo" do
      project = Project.new('repo_dir')
      project.stub(:git_dir).and_return('git_dir')
      File.should_receive(:exist?).with('git_dir').and_return(true)
      project.repo_dir?.should == true
    end
  end

  describe "#clone" do
    it "clones the repo_url" do
      repo_url = 'repo_url'
      repo_url.stub(:repo_url?).and_return(true)
      project = Project.new(repo_url)
      project.should_receive(:run).with("git clone repo_url")
      project.clone
    end
  end

  describe "#add_config_to_repo(key, value)" do
    it "adds a key value pair to the git config" do
      project = Project.new('repo_dir')
      project.stub(:inside).with('repo_dir').and_yield
      project.should_receive(:run).with("git config --add \"key\" \"value\"")
      project.add_config_to_repo('key', 'value')
    end
  end

  describe "#set_runner" do
    it "sets the runner git config entry" do
      project = Project.new('repo_dir')
      project.should_receive(:add_config_to_repo).with("cijoe.runner", 'runner')
      project.set_runner('runner')
    end
  end

  describe "#set_campfire" do
    it "sets campfire values in the git config" do
      project = Project.new('repo_dir')
      project.should_receive(:add_config_to_repo).with("campfire.camp", 'fire')
      project.should_receive(:add_config_to_repo).with("campfire.fire", 'camp')
      project.set_campfire({:camp => 'fire', :fire => 'camp'})
    end
  end

  describe "#port" do
    it "determines what port cijoe is running on" do
      project = Project.new('repo_dir')
      Controller.should_receive(:port).with('repo_dir').and_return(4567)
      project.port.should == 4567
    end
  end
end