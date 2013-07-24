function changeToInvalid() {
  $('#import, #validate').addClass('hidden');
  $('#invalid').removeClass('hidden');
}

function changeToImport() {
  $('#invalid, #validate').addClass('hidden');
  $('#import').removeClass('hidden');
}

function changeToValidate() {
  $('#invalid, #import').addClass('hidden');
  $('#validate').removeClass('hidden');
}

function validateInput() {
  $el = $('.phone-numbers');
  var dirtyValue = $el.val();
  var cleanValue = dirtyValue.replace(/[^\d\s]/g, '');
  $el.val(cleanValue);

  var match = cleanValue.match(/\s*\d{10}(\s+\d{10})*\s*/m);
  var valid = match && (match[0] === cleanValue);

  $('.form-actions').removeClass('hidden');

  if (valid) {
    changeToImport();
  } else {
    changeToInvalid();
  }
}

$('.phone-numbers').on('keyup', validateInput);

$('.phone-numbers').on('change', validateInput);

$('#validate, #invalid').on('click', function(e) {
  e.preventDefault();
  validateInput();
});
