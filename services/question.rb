Kernel.at_exit do
  registry = Service::Question.service_discovery
  response = HTTParty.delete("#{registry}/service", body: { name: 'question', host: Service::Question.settings.host, port: Service::Question.settings.port })
  puts response.body
  Service::Question.quit!
end
require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require 'sinatra/soap'
require 'pry'
require_relative '../utils/system_load_metrics'
require_relative 'model'

module Service
  class Question < Sinatra::Base
    register Sinatra::Soap
    set :service, 'question'
    set :namespace, 'http://schemas.xmlsoap.org/wsdl/'
    set :endpoint, '/action'
    set :wsdl_route, '/wsdl'
    set :host, ENV['HOST'] || 'http://localhost'

    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3003
      enable :logging
    end

    soap '/get_question', in: { question_id: :string }, out: { question: :string } do
      @question = QuestionStore[params['question_id'].to_i]
      @question.ui_json.to_json
    end

    soap '/get_questions', in: nil, out: {questions: :string} do
    end

    soap '/post_question', in: {description: :string}, out: {question: :string} do
      @question = QuestionStore.new(description: params['description'])
      @question.save
    end

    get '/' do
      "Received params: #{params} for Question"
    end

    get '/get_questions' do
      QuestionStore.all.to_a.collect(&:ui_json).to_json
    end

    get '/get_question' do
      @question = QuestionStore[params['question_id'].to_i]
      @question.ui_json.to_json
    end

    get '/post_question' do
      @question = QuestionStore.new(description: params['description'])
      @question.save
      @question.attributes.merge(@question.to_hash).to_json
    end

    get '/healthcheck' do
      SystemLoadMetrics.average_load
    end

    def self.service_discovery
      registries = ['http://localhost:4567','http://localhost:4568']
      registries.each do |registry|
        break(registry) if service_discovery_working?(registry)
      end
    end

    def self.service_discovery_working?(registry)
      HTTParty.get(registry)
      true
    rescue Errno::ECONNREFUSED
      false
    end

    def self.notify_service_and_run!
      registry = service_discovery
      HTTParty.post("#{registry}/service", body: { name: 'question', host: settings.host, port: settings.port, service_load: SystemLoadMetrics.average_load, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
