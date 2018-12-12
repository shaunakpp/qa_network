require 'ohm'
module ServiceDiscovery
  class Service < Ohm::Model
    attribute :name
    attribute :host
    attribute :port
    attribute :weight
    attribute :service_load
    attribute :expiry
    index :name
    index :host
    index :port
  end
end
