require 'sinatra'
require 'sinatra/contrib'
module Service
  class Answer < Sinatra::Base
    configure do
      set :app_file, __FILE__
      set :port, 3003
    end

    get '/' do
      'Answer'
    end

    get '/healthcheck' do
      '300'
    end

    run! if app_file == $0
  end
end
