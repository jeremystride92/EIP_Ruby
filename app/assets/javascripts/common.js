jQuery(function() {
  $("a[rel=popover]").popover();
  $(".tooltip").tooltip();
  $("a[rel=tooltip]").tooltip();
});

function countCharacters($input, $label, maxCharCount) {
  $input.keyup(function() {
    var count = $input.val().length;
    $label.text('(' + (maxCharCount - count) + ' characters remaining)');
  });
}

function manageBatchRows(template, $container, focusField, defaultRecord) {
  var fieldsTemplate = JST[template];
  var $batchArea = $container.find('.batch-rows');

  $container.delegate('.button-add', 'click', function(e) {
    e.preventDefault();

    var $button = $(e.currentTarget);
    var index = $button.data('index');

    var nextIndex = new Date().getTime();
    $batchArea.append(fieldsTemplate(_.extend({ index: nextIndex }, defaultRecord)));
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
    if ($batchArea.children().length === 0) {
      $batchArea.append(fieldsTemplate(_.extend({ index: new Date().getTime() }, defaultRecord)));
    }
  });
}

function populateBatchRows(template, $container, records) {
  var fieldsTemplate = JST[template];
  var $batchArea = $container.find('.batch-rows');

  _.each(records, function(r) {
    var index = new Date().getTime();

    $batchArea.append(fieldsTemplate(_.extend({ index: index }, r)));
  });
}
