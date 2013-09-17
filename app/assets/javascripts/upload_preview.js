//= require binaryajax
//= require exif
function readImagePreview(input, $preview) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      $preview.attr('src', e.target.result).removeClass('hidden');
    };

    reader.readAsDataURL(input.files[0]);
  }
};

function readImagePreviewToBackground(input, $preview) {
  if (input.files && input.files[0]) {
    var stringReader = new FileReader();
    var binaryReader = new FileReader();

    stringReader.onload = function(e) {
      $preview.css('background-image', 'url(' + e.target.result + ')');
    };

    binaryReader.onloadend = function(e) {
      var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));

      for (var i = 1; i <= 8; i++) {
        $preview.removeClass('orientation-' + i);
      }

      if (exif && exif.Orientation) {
        $preview.addClass('orientation-' + exif.Orientation);
      }
    };

    stringReader.readAsDataURL(input.files[0]);
    binaryReader.readAsBinaryString(input.files[0]);
  }
};
