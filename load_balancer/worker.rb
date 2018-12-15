require 'httparty'
require 'queryparams'
require 'savon'
require 'pry'
require 'sidekiq'
module LoadBalancer
  class AaramWorker
    include Sidekiq::Worker
    def perform(service, params, operation=nil)
      service = JSON.parse(service)
      query = QueryParams.encode(params)
      puts "Picked service: #{service}, for operation: #{operation} with query: #{params}"
      res = HTTParty.get("#{service['host']}:#{service['port']}/#{operation}?#{query}")
      puts "Received response: code:#{res.code}, body: #{res.body}, message: #{res.message}"
      {code: res.code, body: res.body, message: res.message}
    end
  end

  class SabunWorker
    include Sidekiq::Worker
    def perform(service, params)
      service = JSON.parse(service)
      client = Savon.client(wsdl: "#{service['host']}:#{service['port']}/wsdl")
      client.call(params['service'].to_sym, message: params['service_params'])
    end
  end
end
