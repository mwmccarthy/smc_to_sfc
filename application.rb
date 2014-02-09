require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'sass'
require 'coffee-script'

require_relative 'models/smc_rom'

class SassEngine < Sinatra::Base

  set :views,   File.dirname(__FILE__)    + '/assets/sass'

  get '/stylesheets/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end

end

class CoffeeEngine < Sinatra::Base

  set :views,   File.dirname(__FILE__)    + '/assets/coffeescript'

  get '/javascripts/*.js' do
    filename = params[:splat].first
    coffee filename.to_sym
  end

end

class Application < Sinatra::Base

  enable :sessions

  register Sinatra::Flash

  use SassEngine
  use CoffeeEngine

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