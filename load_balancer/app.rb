Kernel.at_exit do
  registry = LoadBalancer::Application.service_discovery
  HTTParty.delete("#{registry}/service", body: LoadBalancer::Application.service_details)
  LoadBalancer::Application.quit!
end
require 'sinatra/base'
require 'sinatra/contrib'
require_relative 'worker'
require_relative 'balancer'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'

module LoadBalancer
  class Application < Sinatra::Base
    register Sinatra::ServiceDiscoveryChecker

    configure do
      set :bind, '0.0.0.0'
      set :run, false
      set :app_file, __FILE__
      set :port, ENV['PORT'] || 9292
      set :service, 'load_balancer'
      set :host, ENV['HOST'] || 'http://localhost'
      set :weight, ENV['WEIGHT'] || 1
      enable :logging
    end

    get '/' do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      res = AaramWorker.new.perform(service.to_json, params['service_params'], params['operation'])
      [200, { 'Content-Type' => 'Application/JSON' }, res[:body]]
    end

    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
