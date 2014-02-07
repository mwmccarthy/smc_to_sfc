require 'yaml'

class SmcRom

  attr_reader :name, :country, :video, :licensee, :version

  def initialize(smc_file, file_name)
    @smc_file = smc_file
    @file_size = File.size(@smc_file)
    @file_name = file_name
    @byte_array = build_byte_array
    @header = @byte_array[0..511]
    @dump_size = @header[0..1].reverse.map { |e| e.to_s(16) }.join.to_i(16)

    raise ArgumentError, 'not a valid .smc ROM' unless is_smc_rom?

    @dump = @byte_array[512..-1]
    @offset = detect_offset
    @name = @dump[0xffc0 + @offset..0xffd4 + @offset].map { |b| b.chr }.join
    @country_code = @dump[0xffd9 + @offset]
    @country = detect_country
    @video = detect_video
    @license_code = @dump[0xffda + @offset]
    @licensee = detect_licensee
    @version = "1.#{@dump[0xffdb + @offset]}"
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

    def detect_offset
      or1 = @dump[0x7fde] | @dump[0x7fdc]
      or2 = @dump[0x7fdf] | @dump[0x7fdd]
      or3 = @dump[0xffde] | @dump[0xffdc]
      or4 = @dump[0xffdf] | @dump[0xffdd]

      if [or1, or2].all? { |e| e == 0xff }
        -0x8000
      elsif [or3, or4].all? { |e| e == 0xff }
        0x00
      else
        -0x8000
      end
    end

    def detect_country
      hsh = {}
      File.open('data/countries.yaml', 'r') do |f|
        hsh = YAML.load f
      end
      hsh[@country_code] ? hsh[@country_code] : ''
    end

    def detect_video
      case
      when @country_code.between?(0x02, 0x0c)
        'PAL'
      when [0x00, 0x01, 0x0d].include?(@country_code)
        'NTSC'
      else
        ''
      end
    end

    def detect_licensee
      if @license_code == 0x33
        @dump[0xffb2 + @offset..0xffb5 + @offset].map { |b| b.chr }.join
      else
        hsh = {}
        File.open('data/licenses.yaml', 'r') do |f|
          hsh = YAML.load f
        end
        hsh[@license_code] ? hsh[@license_code] : ''
      end
    end

end