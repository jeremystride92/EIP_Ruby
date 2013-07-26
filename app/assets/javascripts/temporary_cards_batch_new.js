//= require temporary_card_batch_fields
//= require temporary_card_batch_benefit_fields

function manageBatchRows(template, $container, focusField) {
  var fieldsTemplate = JST[template];
  var $batchArea = $container.find('.batch-rows');

  $container.delegate('.button-add', 'click', function(e) {
    e.preventDefault();

    var $button = $(e.currentTarget);
    var index = $button.data('index');

    var nextIndex = new Date().getTime();
    $batchArea.append(fieldsTemplate({ index: nextIndex }));
    $('#batch_' + (nextIndex) + '_' + focusField).focus();
  });

  $batchArea.delegate('.button-remove', 'click', function(e) {
    e.preventDefault();
    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $fieldset = $('.batch-fields[data-index="' + index + '"]');

    $fieldset.remove();
  });

  $(function() {
    $batchArea.append(fieldsTemplate({ index: new Date().getTime() }));
  });
}

manageBatchRows('temporary_card_batch_fields', $('.batch-temporary-cards'), 'phone_number');
manageBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), 'description');
