require 'sinatra/base'
require 'sinatra/contrib'
require 'httparty'
require 'pry'
module Client
  class Application < Sinatra::Base
    configure do
      set :port, 3000
      enable :logging
    end

    before do
      @balancer = load_balancer
    end

    get '/' do
      redirect '/questions'
    end

    get '/questions/new' do
      erb :layout, layout: false do
        erb :'questions/new'
      end
    end


    get '/questions' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=question&operation=get_questions")
      @questions = JSON.parse(resp.body)
      erb :layout, layout: false do
        erb :'questions/index'
      end
    end

    get '/questions/:id' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=question&operation=get_question&service_params[question_id]=#{params[:id]}")
      if resp.body.empty?
        @question = {}
      else
        @question = JSON.parse(resp.body)
      end

      erb :layout, layout: false do
        erb :'questions/show'
      end
    end

    post '/questions' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=question&operation=post_question&service_params[question]=#{params[:description]}")
      resp.body
      redirect '/questions'
    end

    get '/questions/:question_id/answers' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=answer&operation=get_answer_for_question&service_params[question_id]=#{params[:question_id]}")
      @answers = JSON.parse(resp.body)
      erb :layout, layout: false do
        erb :'answers/index'
      end
    end

    get '/questions/:question_id/answers/new' do
      erb :layout, layout: false do
        erb :'answers/new'
      end
    end

    get '/questions/:question_id/answers/:id' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=answer&operation=get_answer&service_params[answer_id]=#{params[:id]}")
      resp.body
      erb :layout, layout: false do
        erb :'answers/show'
      end
    end

    post '/questions/:question_id/answers' do
      resp = HTTParty.get("#{@balancer['host']}:#{@balancer['port']}/rest?service=answer&operation=post_answer&service_params[answer]=#{params['description']}&service_params[question_id]=#{params['question_id']}")
      resp.body
      redirect "/questions/#{params[:question_id]}/answers"
    end

    def load_balancer
      resp = HTTParty.get('http://localhost:4567/service?service=load_balancer')
      balancers = JSON.parse(resp.body)
      balancers.each do |balancer|
        break(balancer) if balancer_working?(balancer)
      end
    end

    def balancer_working?(balancer)
      HTTParty.get("#{balancer['host']}:#{balancer['port']}")
      true
    rescue Errno::ECONNREFUSED
      false
    end

    run! if app_file == $PROGRAM_NAME
  end
end
