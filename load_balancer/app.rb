require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/soap'
require_relative 'worker'
require_relative 'balancer'
module LoadBalancer
  class Application < Sinatra::Base
    register Sinatra::Soap
    set :wsdl_route, '/wsdl'

    soap 'call', in: { service: :string, service_params: {} }, out: nil do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      SabunWorker.perform_async(service.to_json, params['service_params'])
      nil
    end

    get '/' do
      "You've reached the Load Balancer. User /rest for RESTful requests, and /call for SOAP requests"
    end

    get '/rest' do
      balancer = Balancer.new(Request.new(params['service']))
      service = balancer.calculate_load
      AaramWorker.perform_async(service.to_json, params['service_params'])
      'ACK'
    end

    get '/perform' do
      'Performed operation!'
    end
  end
end
