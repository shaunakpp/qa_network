require 'httparty'
require 'queryparams'
require 'savon'
require 'pry'
module LoadBalancer
  class AaramWorker
    include Sidekiq::Worker
    def perform(service, params)
      service = JSON.parse(service)
      params["callback_url"] = "http://localhost:9292/callback"
      query = QueryParams.encode(params)
      res = HTTParty.get("#{service['host']}:#{service['port']}/?#{query}")
      # TODO: send response to callback URL of client
      puts "body: #{res.body} code: #{res.code} message: #{res.message}"
    end
  end

  class SabunWorker
    include Sidekiq::Worker
    def perform(service, params)
      service = JSON.parse(service)
      client = Savon.client(wsdl: "#{service['host']}:#{service['port']}?wsdl")
      res = client.call(params['operation'].to_sym, message: params)
      puts "body: #{res.body}"
    end
  end
end
