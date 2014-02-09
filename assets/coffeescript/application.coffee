$ ->
  $('#flash').fadeOut 3000
  $('#rom_file').change ->

    if window.File and window.FileReader and window.FileList and window.Blob
      rom = $('#rom_file')[0].files[0]
      [fname, fsize] = [rom.name, rom.size]
      pattern = /\.smc$/i

      unless fsize <= 0x600200 and pattern.test(fname) and fsize % 0x400 is 0x200
        $('#rom_file').val ''
        $('#error').html fname + ' is not a valid .smc ROM.'
        $('#error').fadeIn 1
        $('#error').fadeOut 3000
        return

      reader = new FileReader()
      reader.onload = (evt) ->
        array_buffer = evt.target.result
        header = new Uint8Array array_buffer, 0, 0x200
        dump = new Uint8Array array_buffer, 0x200
        o = detect_offset dump
        $('#name').html String.fromCharCode(dump.subarray(0xffc0+o, 0xffc0+o+21)...)
        $('#video').html detect_video(dump[0xffd9+o])
        $('#version').html "1.#{dump[0xffdb+o]}"
      reader.readAsArrayBuffer rom

    else
      alert 'Your browser is not fully supported.'

detect_offset = (dump) ->
  [i, offset] = [0xffdc, -0x8000]
  xor = ((dump[i] << 0x8) + dump[i+1]) ^ ((dump[i+2] << 0x8) + dump[i+3]);
  if xor is 0xffff then 0 else offset

detect_video = (code) ->
  if 0x02 <= code <= 0x0c then 'PAL' else 'NTSC'