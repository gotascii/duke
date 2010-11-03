module Duke
  class App < Sinatra::Base
    get '/' do
      @projects = Project.all
      erb :index
    end
  end
end