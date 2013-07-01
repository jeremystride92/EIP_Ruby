$('#card_level_id').change(function() {
  $('#card_level_form').submit();
});

$('.accordion-header').click(function(e) {
  var $header = $(e.currentTarget);
  $header.toggleClass('info');
  $header.siblings('.accordion-header').removeClass('info');
  var $body = $header.next('.accordion-body');
  $body.siblings('.accordion-body').addClass('hidden');
  $body.toggleClass('hidden').removeClass('success');
});

// Card-level change form /////////////////////////////////////////////////////

$('form.change-card-level select').change(function(e) {
  var $body = $(e.currentTarget).parents('.accordion-body');
  var $header = $body.prev('.accordion-header');

  $body.addClass('warning');
  $header.addClass('warning');
});

$('form.change-card-level').bind("ajax:success", function(xhr, data) {
  var $body = $(xhr.currentTarget).parents('.accordion-body');
  var $header = $body.prev('.accordion-header');

  $body.removeClass('warning').addClass('success');
  $header.removeClass('warning');

  $header.find('.card-level').text(data.card_level.name);
  $body.find('.card-level').text(data.card_level.name);
  $body.find('.card-preview').removeClass(function(index, classes) {
        return (classes.match(/\btheme-\S+/g) || []).join(' ');
      }).addClass('theme-' + data.card_level.theme);
});

$('form.change-card-level').bind("ajax:error", function(xhr, data) {
  var $body = $(xhr.currentTarget).parents('.accordion-body');
  var $header = $body.prev('.accordion-header');

  $body.removeClass('warning').addClass('error');
});


// Status change form /////////////////////////////////////////////////////////

$('form.change-card-status').bind('ajax:success', function(xhr, data) {
  var $form = $(xhr.currentTarget),
      $button = $form.find('input[type="submit"]'),
      $row = $form.parents('tr').prev('.accordion-header'),
      otherLabels = { "Activate": "Deactivate", "Deactivate": "Activate" },
      route = $form.attr('action'),

  if (/\/activate/.test(route)) {
    route = route.replace(/\/activate/, '/deactivate');
  } else {
    route = route.replace(/\/deactivate/, '/activate');
  }
  $form.attr('action', route);
  $button.val(otherLabels[$button.val()]);
  $button.toggleClass('btn-warning btn-success');
  $row.toggleClass('status-inactive status-active');
});

$('form.change-card-status').bind('ajax:error', function(xhr, data) {
  var $body = $(xhr.currentTarget).parents('tr');
  $body.addClass('error');
});

// Approve Card form ///////////////////////////////////////////////////////////

$('form.approve-card').bind('ajax:success', function(xhr, data){
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('.pending-card');

  $row.removeClass('error').addClass('success').fadeOut();
});

$('form.approve-card').bind('ajax:error', function(xhr, data){
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('.pending-card');

  $row.addClass('error');
});
