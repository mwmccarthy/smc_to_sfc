$(document).ready(function(){
  $("#flash").fadeOut(3000);

  // 6291968 max ROM size
  $('#rom_file').change( function() {
    if (window.File && window.FileReader && window.FileList && window.Blob)
    {
        var fsize = $('#rom_file')[0].files[0].size;
        var fname = $('#rom_file')[0].files[0].name;
        var pattern = /\.smc$/;
       
        if ((fsize > 6291968) || !pattern.test(fname))
        {
            alert(fname +" is not a valid .smc ROM.");
            $('#rom_file').val('');
        }
    }else{
        alert("Your browser is not supported.");
        $('#rom_file').val('');
    }
  });
});