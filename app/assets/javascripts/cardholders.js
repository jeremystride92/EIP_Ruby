//= require select_replacement

$('.search-query + .btn').on('click.clear-search', function(e){
  $(e.currentTarget).parents('form').find('.search-query').val('');
});

$('.search-query').on('keydown', function(e){
  $(e.currentTarget).next('.btn').off('click.clear-search').find('.icon-remove').removeClass('icon-remove').addClass('icon-search');
});


$(function(){
  $('select#card_level_id').each(function(i,v){
    var $select = $(v);

    //Establish primative's state:
    var placeholder_text;
    var opt_pairs = _($select.find('option')).chain().filter(function(v,i){
      if( $(v).val() === ''){
        placeholder_text = $(v).text();
        return false;
      }

      return true;
    }).map(function(v,i){
      return {
        label: $(v).text(),
        id: $(v).val()
      };
    }).value();
    var selected_text = (_.findWhere(opt_pairs,{id: $select.val()}) || {}).label || "";

    var typeahead_template = JST['select_replacement'];
    var $container = $(typeahead_template({
      placeholder: placeholder_text,
      selected_text: selected_text
    }));

    //create replacement elements
    var $input = $container.find('.filter-entry');
    var $hidden = $container.find('input[type=hidden]');

    var $clear = $container.find('.clear-button');

    
    $select.replaceWith($container);

    $clear.on('click', function(e){
      $input.val('');
      $hidden.val('');
      $hidden.parents('form').submit();
    });

    //setup strings typehaed values
    var opt_strings = _.pluck(opt_pairs,'label');

    //initialize typeahead
    $input.typeahead({
      source: opt_strings,
      minLength: 0,

      updater: function(item){
        $.each(opt_pairs,function(i,v){
          if (v.label === item){
            $hidden.val(v.id||'');
            $hidden.parents('form').submit();
          }
        });
        return item;
      }
    });

  });
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

  $header.find('.card-level-name').text(data.card_level.name);
  $body.find('.card-preview').css('background-image', 'url(' + data.card_level.card_theme.landscape_background + ')');
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
      $row = $form.parents('tr'),
      $rowHeader = $row.prev('.accordion-header'),
      $cardStatus = $row.find('.card-status'),
      otherLabels = { "Activate": "Deactivate", "Deactivate": "Activate", "Active": "Inactive", "Inactive": "Active" },
      route = $form.attr('action');

  if (/\/activate/.test(route)) {
    route = route.replace(/\/activate/, '/deactivate');
  } else {
    route = route.replace(/\/deactivate/, '/activate');
  }
  $form.attr('action', route);
  $button.val(otherLabels[$button.val()]);
  $button.toggleClass('btn-warning btn-success');
  $rowHeader.toggleClass('status-inactive status-active');
  $cardStatus.text(otherLabels[$cardStatus.text()]);
});

$('form.change-card-status').bind('ajax:error', function(xhr, data) {
  var $body = $(xhr.currentTarget).parents('tr');
  $body.addClass('error');
});

// Approve Card form //////////////////////////////////////////////////////////

$('form.approve-card').bind('ajax:success', function(xhr, data) {
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('.pending-card');

  $row.removeClass('error').addClass('success').fadeOut();
});

$('form.approve-card').bind('ajax:error', function(xhr, data){
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('.pending-card');

  $row.addClass('error');
});


// Reset PIN form /////////////////////////////////////////////////////////////
$('form.send-pin-reset').bind('ajax:success', function(xhr, data) {
  var message = data.success ? 'Cardholder PIN reset. SMS sent.' : 'An error occured when resetting PIN. Please contact support.'
  window.alert(message);
});

// Reset PIN form /////////////////////////////////////////////////////////////
$('form.resend-onboarding-sms').bind('ajax:success', function(xhr, data) {
  var message = data.success ? 'Cardholder onboarding SMS re-sent.' : 'An error occured when re-sending the onboarding SMS. Please contact support.'
  window.alert(message);
});

// Delete card form ///////////////////////////////////////////////////////////
$('form.delete-card').bind('ajax:success', function(xhr, data) {
  var $form = $(xhr.currentTarget);
  var $row = $form.parents('tr');
  var $prev_row = $row.prev();

  $row.remove();
  $prev_row.remove();
});
