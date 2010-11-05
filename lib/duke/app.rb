module Duke
  class App < Sinatra::Base
    get '/' do
      @projects = Project.all
      erb :index
    end

    put '/projects/:id' do
      @project = Project.find(:repo_dir => params[:id])
      @project.start(params[:project][:port])
      redirect '/'
    end
  end
end