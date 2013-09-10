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
    var reader = new FileReader();

    reader.onload = function (e) {
      $preview.css('background-image', 'url(' + e.target.result + ')');
    };

    reader.readAsDataURL(input.files[0]);
  }
};
