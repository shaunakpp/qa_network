Kernel.at_exit do
  registry = Service::Answer.service_discovery
  response = HTTParty.delete("#{registry}/service", body: { name: 'answer', host: Service::Answer.settings.host, port: Service::Answer.settings.port })
  puts response.body
  Service::Answer.quit!
end
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/soap'
require 'httparty'
require 'pry'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'
require_relative 'model'
module Service
  class Answer < Sinatra::Base
    extend ServiceDiscoveryChecker
    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3002
      enable :logging
    end

    register Sinatra::Soap
    set :service, 'answer'
    set :namespace, 'http://schemas.xmlsoap.org/wsdl/'
    set :endpoint, '/action'
    set :wsdl_route, '/wsdl'
    set :host, ENV['HOST'] || 'http://localhost'

    soap '/get_answers', in: nil, out: { answers: :string } do
      AnswerStore.all.to_a.collect(&:ui_json).to_json
    end

    soap '/get_answer_for_question', in: { question_id: :string }, out: { answers: :string } do
      AnswerStore.find(question_id: params['question_id'].to_i).collect(&:ui_json).to_json
    end

    soap '/post_answer', in: { description: :string }, out: { answer: :string } do
      @answer = AnswerStore.new(description: params['description'], question_id: params['question_id'])
      @answer.save
    end

    get '/' do
      "Received params: #{params} for Answer"
    end

    get '/get_answers' do
      AnswerStore.all.to_a.collect(&:ui_json).to_json
    end

    get '/get_answer_for_question' do
      AnswerStore.find(question_id: params['question_id'].to_i).collect(&:ui_json).to_json
    end

    get '/get_answer' do
      @answer = AnswerStore[params['answer_id'].to_i]
      @answer.ui_json.to_json
    end

    get '/post_answer' do
      @answer = AnswerStore.new(description: params['description'], question_id: params['question_id'])
      @answer.save
      @answer.attributes.merge(@answer.to_hash).to_json
    end

    get '/healthcheck' do
      SystemLoadMetrics.average_load
    end

    def self.notify_service_and_run!
      registry = service_discovery
      HTTParty.post("#{registry}/service", body: { name: 'answer', host: settings.host, port: settings.port, service_load: SystemLoadMetrics.average_load, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
