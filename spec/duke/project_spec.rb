describe Project do
  it "selects all the dirs that are repos" do
    git1 = double("git1")
    git1.stub(:repo?).and_return(true)
    git2 = double("git2")
    git2.stub(:repo?).and_return(false)

    dirs = ['dir1', 'dir2']
    Project.stub(:new).with('dir1').and_return(git1)
    Project.stub(:new).with('dir2').and_return(git2)

    Dir.should_receive(:[]).with('*').and_return(dirs)
    Project.dirs.should == ['dir1']
  end

  it "creates a new project for each repo" do
    repo = double("repo")
    repos = [repo]
    Project.stub!(:dirs).and_return(repos)
    Project.should_receive(:new).with(repo).and_return(repo)
    Project.all.should == repos
  end
end

describe "An instance of Project" do
  before do
    @name = 'chugr'
    @project = Project.new(@name)
  end

  it "has a name reader" do
    @project.name.should == 'chugr'
  end

  it "has a path to the git config dir" do
    @project.git_path.should == "chugr/.git"
  end

  it "checks to see if git_path exists in order to determine if repo exists" do
    @project.stub(:git_path).and_return('git_path')
    File.should_receive(:exist?).with('git_path').and_return(true)
    @project.repo?.should == true
  end

  it "clones a repo into the repo_path" do
    @project.should_receive(:run).with("git clone repo chugr")
    @project.clone('repo')
  end

  it "adds a key value pair to the git config" do
    @project.stub(:inside).with('chugr').and_yield
    @project.should_receive(:run).with("git config --add \"key\" \"value\"")
    @project.add_config_to_repo('key', 'value')
  end

  # it "sends a request to cijoe to build the project" do
  #   ::Duke::Config.stub!(:cijoe_url).and_return('cijoe_url')
  #   URI.should_receive(:parse).with("http://cijoe_url/name").and_return('uri')
  #   Net::HTTP.should_receive(:post_form).with('uri', {})
  #   @project.build
  # end
end