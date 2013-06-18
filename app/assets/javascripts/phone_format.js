$('input[type=tel]').on('change', function(e) {
  var $el = $(e.currentTarget);
  var dirtyValue = $el.val();
  var cleanValue = dirtyValue.replace(/\D/g, '');
  $el.val(cleanValue);
});
