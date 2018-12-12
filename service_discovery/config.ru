require 'rack/cors'
require_relative '../init'
require_relative 'app'
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end
use Rack::PostBodyContentTypeParser
run ServiceDiscovery::Application
