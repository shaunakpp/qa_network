Kernel.at_exit do
  registry = Service::Question.service_discovery
  HTTParty.delete("#{registry}/service", body: Service::Question.service_details)
  Service::Question.quit!
end

require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require_relative 'model'
require_relative '../utils/system_load_metrics'
require_relative '../utils/service_discovery_checker'
require_relative '../blockchain/block_chain'

module Service
  class Question < Sinatra::Base
    register Sinatra::ServiceDiscoveryChecker

    configure do
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
      set :run, false
      set :port, ENV['PORT'] || 3003
      set :service, 'question'
      set :host, ENV['HOST'] || 'http://localhost'
      set :weight, ENV['WEIGHT'] || 1
      enable :logging
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
      Blockchain.generate_new_block("QUESTION: #{@question.description}")
      @question.attributes.merge(@question.to_hash).to_json
    end

    get '/healthcheck' do
      SystemLoadMetrics.average_load
    end

    notify_service_and_run! if app_file == $PROGRAM_NAME
  end
end
