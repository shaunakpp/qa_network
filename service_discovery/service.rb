module ServiceDiscovery
  class Service
    attr_accessor :name, :weight, :host, :port, :service_load
    def initialize(name, weight, host='http://localhost:', port, service_load)
      @name = name
      @weight = weight
      @host = host
      @port = port
      @service_load = service_load
    end

    def id
      "#{name}-#{host}-#{port}-#{service_load}"
    end

    def to_hash
      {
        id: id,
        name: name,
        host: host,
        port: port,
        weight: weight,
        service_load: service_load
      }
    end

    def to_json(*args)
      to_hash.to_json(*args)
    end
  end
end
