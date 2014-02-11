require 'pry'

class SmcRom

  def initialize(smc_file, file_name)

    @smc_file = smc_file
    @file_size = File.size(@smc_file)
    @file_name = file_name
    @byte_array = build_byte_array
    @header = @byte_array[0..511]

    raise ArgumentError, 'not a valid .smc ROM' unless is_smc_rom?

    @dump = @byte_array[512..-1]

  end

  def convert_to_sfc

    file_name = @file_name.match(/(.*)\.smc$/i)[1] + '.sfc'
    outfile = Tempfile.new('sfc')
    outfile.write @dump.pack('c*')
    [outfile, file_name]

  end

private

    def is_smc_rom?

      @file_name.downcase.match(/\.smc$/) &&
      @file_size <= 6291968 &&
      @file_size % 1024 == 512 &&
      @header.count { |b| b == 0 } > 500

    end

    def build_byte_array

      temp = []
      File.open(@smc_file, 'r') do |f|
        f.each_byte { |b| temp << b }
      end
      temp

    end

end