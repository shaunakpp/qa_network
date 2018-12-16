require 'ohm'
Ohm.redis = Redic.new('redis://127.0.0.1:6379')
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
