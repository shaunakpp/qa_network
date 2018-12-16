Kernel.at_exit do
  registry = LoadBalancer::Application.service_discovery
  response = HTTParty.delete("#{registry}/service", body: { name: 'load_balancer', host: LoadBalancer::Application.settings.host, port: LoadBalancer::Application.settings.port })
  puts response.body
end
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/soap'
require_relative 'worker'
require_relative 'balancer'
require_relative '../utils/system_load_metrics'

module LoadBalancer
  class Application < Sinatra::Base
    register Sinatra::Soap
    set :service, 'load_balancer'
    set :namespace, 'http://schemas.xmlsoap.org/wsdl/'
    set :endpoint, '/action'
    set :wsdl_route, '/wsdl'
    set :host, ENV['HOST'] || 'http://localhost'
    configure do
      set :bind, '0.0.0.0'
      set :run, false
      set :app_file, __FILE__
      set :port, ENV['PORT'] || 9292
      enable :logging
    end

    soap '/call', in: { service: :string, operation: :string, service_params: :string }, out: nil do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      SabunWorker.new.perform(service.to_json, params['service_params'])
    end

    get '/' do
      "You've reached the Load Balancer. User /rest for RESTful requests, and /wsdl for SOAP endpoint"
    end

    get '/rest' do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      res = AaramWorker.new.perform(service.to_json, params['service_params'], params['operation'])
      [200, { 'Content-Type' => 'Application/JSON' }, res[:body]]
    end

    def self.service_discovery
      registries = ['http://localhost:4567', 'http://localhost:4568']
      registries.each do |registry|
        break(registry) if service_discovery_working?(registry)
      end
    end

    def self.service_discovery_working?(registry)
      HTTParty.get(registry)
      true
    rescue Errno::ECONNREFUSED
      false
    end

    def self.notify_service_and_run!
      registry = service_discovery
      HTTParty.post("#{registry}/service", body: { name: 'load_balancer', host: settings.host, port: settings.port, service_load: SystemLoadMetrics.average_load, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
