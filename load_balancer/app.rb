Kernel.at_exit do
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'load_balancer', host: 'http://localhost', port: 9292 })
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
    set :service, "sinatra"
    set :namespace, "http://schemas.xmlsoap.org/wsdl/"
    set :endpoint, '/action'
    set :wsdl_route, '/wsdl'

    configure do
      set :bind, '0.0.0.0'
      set :run, false
      set :app_file, __FILE__
      set :port, 9292
      enable :logging
    end

    soap 'soap_request', in: { service: :string}, out: nil do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      SabunWorker.new.perform(service.to_json, params['service_params'])
    end

    get '/' do
      "You've reached the Load Balancer. User /rest for RESTful requests, and /call for SOAP requests"
    end

    get '/rest' do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      res = AaramWorker.new.perform(service.to_json, params['service_params'])
      [200, { 'Content-Type' => 'Application/JSON' }, res[:body]]
    end

    get '/perform' do
      'Performed operation!'
    end

    def self.notify_service_and_run!
      HTTParty.post('http://localhost:4567/service', body: { name: 'load_balancer', host: 'http://localhost', port: 9292, service_load: 0, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
