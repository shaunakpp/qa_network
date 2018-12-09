module LoadBalancer
  Service = Struct.new(:name, :weight, :host, :port, :service_load) do
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
