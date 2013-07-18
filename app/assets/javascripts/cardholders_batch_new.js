//= require cardholder_batch_fields

(function() {
  var fieldsTemplate = JST['cardholder_batch_fields'];

  $('.batch-cardholders').delegate('#issue-another', 'click', function(e) {
    e.preventDefault();

    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $batchArea = $('.batch-cardholders .batch-rows');

    var nextIndex = new Date().getTime();
    $batchArea.append(fieldsTemplate({ index: nextIndex }));
    $('#cardholders_' + (nextIndex) + '_phone_number').focus();
  });

  $('.batch-cardholders .batch-rows').delegate('.button-remove', 'click', function(e) {
    e.preventDefault();
    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $fieldset = $('.cardholder-fields[data-index="' + index + '"]');

    $fieldset.remove();
  });

  $(function() {
    $('.batch-cardholders .batch-rows').append(fieldsTemplate({ index: 0 }));
  });
})();
