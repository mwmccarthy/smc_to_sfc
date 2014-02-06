$(document).ready(function(){
  $("#flash").fadeOut(3000);

  $('#rom_file').change( function() {
    if (window.File && window.FileReader && window.FileList && window.Blob)
    {
        var fsize = $('#rom_file')[0].files[0].size;
        var fname = $('#rom_file')[0].files[0].name;
        var pattern = /\.smc$/i;
       
        if (fsize > 6291968 || !pattern.test(fname) || fsize % 1024 != 512)
        {
            $('#rom_file').val('');
            $('#error').html(fname +" is not a valid .smc ROM.");
            $("#error").fadeIn(1);
            $("#error").fadeOut(3000);
        }
    }else{
        alert("Your browser is not supported.");
        $('#rom_file').val('');
    }
  });
});