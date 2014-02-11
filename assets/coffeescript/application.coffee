$ ->
  downloadAttributeSupport = 'download' in document.createElement('a')
  blob = null
  blobURL = null
  link = null

  $('#labels').hide(1)
  $('#flash').fadeOut 3000
  $('#rom-file').change ->

    $('#name').html ''
    $('#license').html ''
    $('#country').html ''
    $('#video').html ''
    $('#version').html ''
    $('#labels').hide(1)

    if window.File and window.FileReader and window.FileList and window.Blob
      rom = $('#rom-file')[0].files[0]
      [fname, fsize] = [rom.name, rom.size]
      pattern = /(.*)\.smc$/i

      unless fsize <= 0x600200 and pattern.test(fname) and fsize % 0x400 is 0x200
        $('#rom-file').val ''
        $('#error').html "#{fname} is not a valid .smc ROM."
        $('#error').fadeIn 1
        $('#error').fadeOut 3000
        return

      reader = new FileReader()
      reader.onload = (evt) ->
        arrayBuffer = evt.target.result
        header = new Uint8Array arrayBuffer, 0, 0x200
        dump = new Uint8Array arrayBuffer, 0x200
        o = detectOffset dump
        $('#labels').show(1)
        $('#name').html String.fromCharCode(dump.subarray(0xffc0 + o, 0xffc0 + o + 21)...)
        $.getJSON '/JSON/licenses.json', (licenses) ->
          $('#license').html licenses[dump[0xffda + o]]
        $.getJSON '/JSON/countries.json', (countries) ->
          $('#country').html countries[dump[0xffd9 + o]]
        $('#video').html detectVideo(dump[0xffd9 + o])
        $('#version').html "1.#{dump[0xffdb + o]}"

        if downloadAttributeSupport
          blob = new Blob([arrayBuffer.slice 512])
          blobURL = window.URL.createObjectURL blob
          link = document.createElement('a')
          link.setAttribute 'href', blobURL
          link.setAttribute 'download', "#{pattern.exec(fname)[1]}.sfc"
        #$('#download').attr 'href', blobURL
        #$('#download').attr 'download', "#{pattern.exec(fname)[1]}.sfc"
      reader.readAsArrayBuffer rom

    else
      alert 'Your browser is not fully supported.'

  $('#rom-submit').click (evt) ->
    if downloadAttributeSupport
      evt.preventDefault()
      event = document.createEvent 'MouseEvents'
      event.initMouseEvent 'click', true, true, window, 1, 0, 0, 0, 0, false, false, false, false, 0, null
      link.dispatchEvent event

detectOffset = (dump) ->
  [i, offset] = [0xffdc, -0x8000]
  xor = ((dump[i] << 0x8) + dump[i + 1]) ^ ((dump[i + 2] << 0x8) + dump[i + 3]);
  if xor is 0xffff then 0 else offset

detectVideo = (code) ->
  if 0x02 <= code <= 0x0c then 'PAL' else 'NTSC'