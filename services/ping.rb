require 'sinatra'
require 'sinatra/contrib'
module Service
  class Ping < Sinatra::Base
    configure do
      set :app_file, __FILE__
      set :port, 3000
    end

    get '/' do
      'PING'
    end

    get '/healthcheck' do
      '300'
    end

    run! if app_file == $0
  end
end

