require 'sinatra'
require 'sinatra/contrib'
module Service
  class Question < Sinatra::Base
    configure do
      set :app_file, __FILE__
      set :port, 3002
    end

    get '/' do
      puts "Received params: #{params} for Question"
      "Received params: #{params} for Question"
    end

    get '/healthcheck' do
      '300'
    end

    run! if app_file == $0
  end
end

