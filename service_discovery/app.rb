require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/soap'
require_relative 'service'
module ServiceDiscovery
  class Application < Sinatra::Base
    register Sinatra::Soap
    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, 4567
      enable :logging
    end


    set :wsdl_route, '/wsdl'

    soap 'call', in: { service: :string, service_params: {} }, out: nil do
      nil
    end

    get '/' do
      'PING'
    end

    get '/services' do
      ServiceDiscovery::Service.all.collect { |x| x.attributes.merge(x.to_hash) }.to_json
    end

    get '/service' do
      ServiceDiscovery::Service.find(name: params['service']).collect { |x| x.attributes.merge(x.to_hash) }.to_json
    end

    get '/find' do
      service = ServiceDiscovery::Service[params['service_id']]
      if service.nil?
        status 404
        "Service with id: #{params['service_id']} Not found"
      else
        service.attributes.merge(service.to_hash).to_json
      end
    end

    post '/service' do
      service = Service.find(name: params['name'], host: params['host'], port: params['port']).first
      service = Service.create(params) if service.nil?
      service.update(expiry: 30)
      service.attributes.merge(service.to_hash).to_json
    end

    delete '/service' do
      service = Service.find(name: params['name'], host: params['host'], port: params['port']).first
      if service.nil?
        status 404
        'Service not found'
      else
        id = service.id
        service.delete
        "Service with id #{id} deleted"
      end
    end

    run! if app_file == $PROGRAM_NAME
  end
end
