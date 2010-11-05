module Duke
  class App < Sinatra::Base
    get '/' do
      @projects = Project.all
      erb :index
    end

    get '/:repo_dir/start/:port' do
      @project = Project.find(params[:repo_dir])
      @project.start(params[:port])
      redirect '/'
    end
  end
end