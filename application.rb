require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/json'
require 'coffee-script'
require 'haml'
require 'sass'
require 'yaml'

require_relative 'models/smc_rom'

class AssetsEngine < Sinatra::Base

  set :views,   File.dirname(__FILE__)    + '/assets'

  get '/javascripts/*.js' do
    filename = params[:splat].first
    coffee "coffeescript/#{filename}".to_sym
  end

  get '/stylesheets/*.css' do
    filename = params[:splat].first
    sass "sass/#{filename}".to_sym
  end

  get '/JSON/*.json' do
    filename = params[:splat].first
    json YAML.load_file("assets/YAML/#{filename}.yaml")
  end

end

class Application < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  helpers Sinatra::JSON
  use AssetsEngine

  set :views,   File.dirname(__FILE__)    + '/views'
  set :public,  File.dirname(__FILE__)    + '/public'

  get '/' do
    haml :index, :format => :html5
  end

  post '/convert' do
    unless params['upfile']
      flash[:error] = 'You must to choose a file to convert.'
      redirect '/'
    end

    begin
      smc_rom = SmcRom.new(params['upfile'][:tempfile], params['upfile'][:filename])
    rescue ArgumentError
      flash[:error] = "#{params['upfile'][:filename]} is not a valid .smc ROM."
      redirect '/'
    end

    ofile, fname = smc_rom.convert_to_sfc
    send_file ofile.path, :filename => fname, :type => 'Application/octet-stream'
  end

end