Kernel.at_exit do
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'question', host: 'http://localhost', port: 3003 })
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
    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['port'] || 3003
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

    def self.notify_service_and_run!
      HTTParty.post('http://localhost:4567/service', body: { name: 'question', host: 'http://localhost', port: 3003, service_load: SystemLoadMetrics.average_load, weight: 1 })
      run!
    end
    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
