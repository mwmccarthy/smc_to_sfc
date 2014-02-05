require 'sinatra'
require 'haml'

get '/' do
  haml :index, :format => :html5
end

post '/convert' do
  tempfile = params['upfile'][:tempfile]
  filename = params['upfile'][:filename]

  file_base = filename.split('.')[0..-2].join('.')

  byte_array = []
  File.open(tempfile, 'r') do |f|
    f.each_byte { |b| byte_array << b }
  end

  outfile = Tempfile.new('sfc')

  outfile.write byte_array[512..-1].pack('c*')

  send_file outfile.path, :filename => "#{file_base}.sfc", :type => 'Application/octet-stream'

  outfile.close
  outfile.unlink

  redirect '/'
end