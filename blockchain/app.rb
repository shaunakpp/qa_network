require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'
require_relative 'block_chain'

module Blockchain
  class Application < Sinatra::Base

    configure do
      set :host, ENV['HOST'] || 'http://localhost'
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3005
      enable :logging
    end

    get '/' do
      redirect '/blocks'
    end

    get '/blocks' do
      @block_chain = Blockchain.block_chain.collect(&:ui_json)
      erb :layout, layout: false do
        erb :index
      end
    end

    run! if app_file == $PROGRAM_NAME
  end
end
