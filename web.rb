require 'sinatra'
require 'haml'
require 'sinatra/flash'
require 'sass'

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

  tempfile = params['upfile'][:tempfile]
  filename = params['upfile'][:filename]

  file_base = filename.split('.')[0..-2].join('.')
  file_extension = filename.split('.')[-1]

  unless file_extension == 'smc'
    flash[:error] = 'That\'s not an smc file!'
    redirect '/'
  end

  byte_array = []
  File.open(tempfile, 'r') do |f|
    f.each_byte { |b| byte_array << b }
  end

  remainder = byte_array.size % 1024

  case remainder
  when 0
    send_file tempfile.path, :filename => "#{file_base}.sfc", :type => 'Application/octet-stream'
  when 512
    outfile = Tempfile.new('sfc')
    outfile.write byte_array[512..-1].pack('c*')
    send_file outfile.path, :filename => "#{file_base}.sfc", :type => 'Application/octet-stream'
    outfile.close
    outfile.unlink
  else
    flash[:error] = 'That doesn\'t seem to be a valid SNES ROM.'
    redirect '/'
  end

  redirect '/'
end