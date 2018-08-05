require 'sinatra'
require 'haml'
require 'drb'
require 'json'

DRBSERVER = 'druby://localhost:9001'
MCP = DRbObject.new_with_uri(DRBSERVER)

class MyServer < Sinatra::Application
  set :haml, :format => :html5

  get '/' do
    @title = "Welcome to the MCP"
    @finished,@running = MCP.processes.partition{ |o| o[:results] }
    haml :home
  end

  get '/start' do
    @process_id = MCP.start_new_long_running_thingy
    @title = "Process ##{@process_id} Running"
    haml :start
  end

  get '/status' do
    content_type :json
    MCP.status_for(params[:process_id].to_i).to_json
  end

  get '/results/:process_id' do
    @title = "Results for Process ##{params[:process_id]}"
    @results = MCP.results_for( params[:process_id].to_i )
    haml :results
  end
end

#http://phrogz.net/drb-server-for-long-running-web-processes

