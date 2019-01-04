Kernel.at_exit do
  registry = Service::Answer.service_discovery
  HTTParty.delete("#{registry}/service", body: Service::Answer.service_details)
  Service::Answer.quit!
end

require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require_relative 'model'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'
require_relative '../blockchain/block_chain'

module Service
  class Answer < Sinatra::Base
    register Sinatra::ServiceDiscoveryChecker

    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3002
      set :service, 'answer'
      set :host, ENV['HOST'] || 'http://localhost'
      set :weight, ENV['WEIGHT'] || 1
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
      Blockchain.generate_new_block("ANSWER: #{@answer.description}")
      @answer.attributes.merge(@answer.to_hash).to_json
    end

    get '/healthcheck' do
      SystemLoadMetrics.average_load
    end

    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
