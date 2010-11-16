module Duke
  class App < Sinatra::Base
    helpers do
      def status_style(project)
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
      if @project.running?
        @project.stop
      elsif params[:project][:port]
        @project.start(params[:project][:port])
      end
      redirect Config.host_url
    end

    post '/projects' do
      Project.create(params[:project])
      redirect Config.host_url
    end
  end
end