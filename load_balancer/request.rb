module LoadBalancer
  class Request
    attr_accessor :service
    def initialize(service)
      @service = service
    end
  end
end
