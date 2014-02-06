require 'sinatra'
require 'haml'
require 'sinatra/flash'
require 'sass'
require_relative 'models/smc_rom'

enable :sessions

get '/' do
  haml :index, :format => :html5
end

get '/styles.css' do
  scss :styles
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
  ofile.close
  ofile.unlink

  redirect '/'
end