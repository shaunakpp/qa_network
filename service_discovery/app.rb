require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/soap'
require_relative 'registry'

module ServiceDiscovery
  class Application < Sinatra::Base
    register Sinatra::Soap

    set :wsdl_route, '/wsdl'

    soap 'call', in: { service: :string, service_params: {} }, out: nil do
      nil
    end

    get '/' do
      'PING'
    end

    get '/services' do
      Registry.new.services.to_json
    end

    get '/service' do
      Registry.new.find_all(params['service']).to_json
    end

    get '/find' do
      Registry.new.find(params['service_id']).to_json
    end
  end
end
