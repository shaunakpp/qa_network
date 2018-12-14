Kernel.at_exit {
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'question', host: 'http://localhost', port: 3003 })
  puts response.body
  Service::Question.quit!
}
require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require 'sinatra/soap'

module Service
  class Question < Sinatra::Base
    register Sinatra::Soap
    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, 3003
      enable :logging
    end

    soap 'question', in: {question: :string}, out: {question_id: :string} do
      'FAKE_QUESTION_ID'
    end

    get '/' do
      puts "Received params: #{params} for Question"
      "Received params: #{params} for Question"
    end

    get '/healthcheck' do
      '300'
    end

    def self.notify_service_and_run!
      HTTParty.post('http://localhost:4567/service', body: { name: 'question', host: 'http://localhost', port: 3003, service_load: 200, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME

  end
end

