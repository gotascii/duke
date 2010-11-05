module Duke
  class App < Sinatra::Base
    helpers do
      def status(project)
        if project.built?
          if project.building?
            " building"
          elsif project.passing?
            " pass"
          else
            " fail"
          end
        end
      end
    end

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