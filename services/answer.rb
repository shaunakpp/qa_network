Kernel.at_exit {
  response = HTTParty.delete('http://localhost:4567/service', body: { name: 'answer', host: 'http://localhost', port: 3002 })
  puts response.body
}
require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require 'pry'
require_relative 'model'
module Service
  class Answer < Sinatra::Base
    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, 3002
      enable :logging
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
      [200, { 'Content-Type' => 'Application/JSON' }, @question]
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
