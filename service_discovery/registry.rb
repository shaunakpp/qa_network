require_relative 'constants'
require_relative 'service'
module ServiceDiscovery
  class Registry
    attr_accessor :services
    def initialize
      @services = JSON.parse(File.read('service_discovery/list.json')).collect do |service|
        Service.new(service['name'], service['weight'], service['host'], service['port'], service['service_load'])
      end
    end

    def find(service_id)
      name, host, port, service_load = service_id.split('-')
      @services.find { |x| x.name == name && x.host == host && x.port == port && x.service_load == service_load.to_i }
    end

    def find_all(service_name)
      @services.select { |x| x.name == service_name }
    end
  end
end
