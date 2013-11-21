$('#lookup').click(function(e){
  e.preventDefault();

  $(e.currentTarget).removeClass('btn-primary');

  var $phoneNumber = $("#cardholder_phone_number");
  var $hintBlock = $("#new_cardholder p.instructions");
  var $form = $("#new_cardholder");
  var $signupFields = $form.find('.new-cardholder-fields');
  var $detailFields = $form.find('.detail-fields');

  var handleSuccess = function(data, status, xhr){
    if ($('meta[name=require-pin]').attr('content') == 'true'){
      honeNumber.removeClass('processing');
      $hintBlock.text('Welcome back! Please enter your 4-digit PIN.');
      $signupFields.hide();
      $detailFields.slideDown();
    }

    $('.request-card form')[0].submit();
  };

  var handleFailure = function(status){
    $phoneNumber.removeClass('processing');
    $hintBlock.text('Fill out you information to sign up for EIPiD!');
    $signupFields.show();
    $detailFields.slideDown();
  };

  if ($phoneNumber.is(':invalid')) {
    $hintBlock.text('Enter a valid phone number to continue.');
  } else {
    $.get('/cardholders/' + $phoneNumber.val()).done(handleSuccess).fail(handleFailure);
    $detailFields.slideUp();
    $phoneNumber.addClass('processing');
  }
});

$('.request-card form').submit(function(e){
  var $form = $(e.currentTarget);

  if (!$form.find('.detail-fields').is(':visible')) {
    e.preventDefault();
  }
});
