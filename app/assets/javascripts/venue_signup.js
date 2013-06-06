function readUrl(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      $('#logo-img').attr('src', e.target.result).removeClass('hidden');
    };

    reader.readAsDataURL(input.files[0]);
  }
};


$('#venue_logo').change(function() { readUrl(this); });
