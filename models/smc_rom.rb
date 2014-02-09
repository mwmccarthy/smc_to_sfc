class SmcRom

  def initialize(smc_file, file_name)

    @smc_file = smc_file
    @file_size = File.size(@smc_file)
    @file_name = file_name
    @byte_array = build_byte_array
    @header = @byte_array[0..511]
    @dump_size = @header[0..1].reverse.map { |e| e.to_s(16) }.join.to_i(16)

    raise ArgumentError, 'not a valid .smc ROM' unless is_smc_rom?

  end

  def convert_to_sfc

    file_name = @file_name.downcase.match(/(.*)\.smc$/)[1] + '.sfc'
    outfile = Tempfile.new('sfc')
    outfile.write @dump.pack('c*')
    [outfile, file_name]

  end

private

    def is_smc_rom?

      @file_name.downcase.match(/\.smc$/) &&
      @file_size <= 6291968 &&
      @file_size % 1024 == 512 &&
      @header.count { |b| b == 0 } > 500 &&
      @dump_size.between?(0x20, 0x300)

    end

    def build_byte_array

      temp = []
      File.open(@smc_file, 'r') do |f|
        f.each_byte { |b| temp << b }
      end
      temp

    end

end