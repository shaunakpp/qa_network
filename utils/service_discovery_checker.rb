require 'sinatra/base'

module Sinatra
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

    def self.notify_service_and_run!
      HTTParty.post("#{service_discovery}/service", body: service_details)
      run!
    end

    def self.service_details
      {
        name: settings.service,
        host: settings.host,
        port: settings.port,
        service_load: SystemLoadMetrics.average_load,
        weight: settings.weight
      }
    end
  end
end
