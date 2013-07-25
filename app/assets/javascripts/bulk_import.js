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

  var valid = cleanValue.match(/^\s*\d{10}(\s+\d{10})*\s*$/);

  $('.form-actions').removeClass('hidden');

  if (valid) {
    changeToImport();
  } else {
    changeToInvalid();
  }
}

$('.phone-numbers').on('keyup change', validateInput);

$('#validate, #invalid').on('click', function(e) {
  e.preventDefault();
  validateInput();
});
