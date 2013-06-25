$('.request-card form #cardholder_phone_number').change(function(e){
  var $phone_number = $(e.currentTarget);
  var $hint_block = $(e.currentTarget).siblings('.help-block');
  var $form = $(e.currentTarget).parents('form');
  var $signup_fields = $form.find('.new-cardholder-fields');
  var $detail_fields = $form.find('.detail-fields');


  var dirtyValue = $phone_number.val();
  var cleanValue = dirtyValue.replace(/\D/g, '');
  $phone_number.val(cleanValue);

  var handleSuccess = function(data, status, xhr){
    $phone_number.removeClass('processing');
    $hint_block.text('Welcome back! Enter your password');
    $signup_fields.hide();
    $detail_fields.slideDown();
  };
  var handleFailure = function(status){
    $phone_number.removeClass('processing');
    $hint_block.text('Fill out you information to sign up for EIPiD!');
    $signup_fields.show();
    $detail_fields.slideDown();
  };

  $.get('/cardholders/' + $phone_number.val()).done(handleSuccess).fail(handleFailure);
  $detail_fields.slideUp();
  $phone_number.addClass('processing');

});

$('.request-card form').submit(function(e){
  var $form = $(e.currentTarget);

  if (!$form.find('.detail-fields').is(':visible')) {
    e.preventDefault();
  }
});
