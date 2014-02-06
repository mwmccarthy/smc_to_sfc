class SmcRom

  def initialize(smc_file, file_name)
    @smc_file = smc_file
    @file_name = file_name
    raise ArgumentError, 'not a valid .smc ROM' unless is_smc_rom?(@smc_file, @file_name)
    
    @byte_array = []
    File.open(@smc_file, 'r') do |f|
      f.each_byte { |b| @byte_array << b }
    end
  end

  def is_smc_rom?(smc_file, file_name)
    file_size = File.size(smc_file)
    header = smc_file.each_byte.to_a[0..511]
    dump_size = header[0..1].reverse.map { |e| e.to_s(16) }.join.to_i(16)

    file_name.downcase.match(/\.smc$/) &&
    file_size <= 6291968 &&
    file_size % 1024 == 512 &&
    header.count { |b| b == 0 } > 500 &&
    dump_size.between?(0x20, 0x300)
  end

  def convert_to_sfc
    file_name = @file_name.downcase.match(/(.*)\.smc$/)[1] + '.sfc'
    outfile = Tempfile.new('sfc')
    outfile.write @byte_array[512..-1].pack('c*')
    [outfile, file_name]
  end
end