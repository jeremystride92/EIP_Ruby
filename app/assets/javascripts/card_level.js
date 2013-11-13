$('form.delete-card-level').bind('ajax:success', function(xhr, data) {
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('li.card-level-listing');

  $row.remove();
});

console.log('loaded');