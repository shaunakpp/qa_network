Kernel.at_exit do
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'load_balancer', host: 'http://localhost', port: LoadBalancer::Application.settings.port })
  puts response.body
end
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/soap'
require_relative 'worker'
require_relative 'balancer'
module LoadBalancer
  class Application < Sinatra::Base
    register Sinatra::Soap
    set :service, 'load_balancer'
    set :namespace, 'http://schemas.xmlsoap.org/wsdl/'
    set :endpoint, '/action'
    set :wsdl_route, '/wsdl'

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

    def self.notify_service_and_run!
      HTTParty.post('http://localhost:4567/service', body: { name: 'load_balancer', host: 'http://localhost', port: settings.port, service_load: 1, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
