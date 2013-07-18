//= require cardholder_batch_fields

(function() {
  var fields_template = JST['cardholder_batch_fields'];

  $('.batch_cardholders').delegate('#issue_another', 'click', function(e) {
    e.preventDefault();

    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $batch_area = $('.batch_cardholders .batch_rows');

    var nextIndex = new Date().getTime();
    $batch_area.append(fields_template({ index: nextIndex }));
    $('#cardholders_' + (nextIndex) + '_phone_number').focus();
  });

  $('.batch_cardholders .batch_rows').delegate('.button-remove', 'click', function(e) {
    e.preventDefault();
    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $fieldset = $('.cardholder_fields[data-index="' + index + '"]');

    $fieldset.remove();
  });

  $(function() {
    $('.batch_cardholders .batch_rows').append(fields_template({ index: 0 }));
  });
})();
