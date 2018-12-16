module ServiceDiscoveryChecker
  def service_discovery
    registries = ['http://localhost:4567', 'http://localhost:4568']
    registries.each do |registry|
      break(registry) if service_discovery_working?(registry)
    end
  end

  def service_discovery_working?(registry)
    HTTParty.get(registry)
    true
  rescue Errno::ECONNREFUSED
    false
  end
end
