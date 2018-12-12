Kernel.at_exit {
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'answer', host: 'http://localhost', port: 3002 })
  puts response.body
}
require 'sinatra'
require 'sinatra/contrib'
require 'httparty'
module Service
  class Answer < Sinatra::Base
    configure do
      set :app_file, __FILE__
      set :port, 3002
    end

    get '/' do
      "Received params: #{params} for Answer"
    end

    get '/healthcheck' do
      '300'
    end
    def self.notify_service_and_run!
      HTTParty.post('http://localhost:4567/service', body: { name: 'answer', host: 'http://localhost', port: 3002, service_load: 220, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
