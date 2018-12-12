require 'httparty'
require_relative 'request'
require_relative 'service'
module LoadBalancer
  class Balancer
    attr_accessor :service, :request
    def initialize(request)
      @request = request
    end

    def calculate_load
      @service = minimum_load_service
    end

    def services
      @services ||= parse(HTTParty.get("http://localhost:4567/service?service=#{request.service}"))
    end

    private

    def minimum_load_service
      services.min do |service|
        service.service_load * service.weight
      end
    end

    def parse(response)
      JSON.parse(response).collect do |s|
        Service.new(s['name'], s['weight'].to_i, s['host'], s['port'].to_i, s['service_load'].to_i)
      end
    end
  end
end


