Kernel.at_exit do
  # registry = Service::Question.service_discovery
  # response = HTTParty.delete("#{registry}/service", body: { name: 'question', host: Service::Question.settings.host, port: Service::Question.settings.port })
  # puts response.body
  # Service::Question.quit!
end

require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
# require 'sinatra/soap'
require 'pry'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'
require_relative 'block_chain'

module Blockchain
  class Application < Sinatra::Base
    # extend ServiceDiscoveryChecker
    # register Sinatra::Soap
    # set :service, 'question'
    # set :namespace, 'http://schemas.xmlsoap.org/wsdl/'
    # set :endpoint, '/action'
    # set :wsdl_route, '/wsdl'
    set :host, ENV['HOST'] || 'http://localhost'

    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3003
      enable :logging
    end

    get '/blocks' do
      @block_chain = Blockchain.block_chain.collect { |x| x.ui_json }
      erb :layout, layout: false do
        erb :index
      end
    end

    get '/mine_block' do

    end

    def self.notify_service_and_run!
      # registry = service_discovery
      # HTTParty.post("#{registry}/service", body: { name: 'question', host: settings.host, port: settings.port, service_load: SystemLoadMetrics.average_load, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
