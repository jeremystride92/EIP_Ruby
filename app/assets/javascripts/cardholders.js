//= require select_replacement

var load_cardholders = function(url, tabname) {
  $("#ajax_loader").removeClass("hide");
  $(".nav-tabs li").addClass("disabled");
  $(".nav-tabs li a").blur();
  $(".nav-tabs li a").removeAttr("data-toggle");
  
  $.ajax({
    method: "GET",
    url: url 
  }).done(function(data, textStatus, jqXHR) {
    $(".tab-pane.active").html(data); 
    $("#ajax_loader").addClass("hide");
    $(".nav-tabs li a").attr("data-toggle", "tab");
    $(".nav-tabs li").removeClass("disabled");
    window["bind_" + tabname + "_view"]();
  }); 

  $(".tab-pane.active").empty(); 
};

var form_submitted = function(e) {

  var url = $(e.currentTarget).attr("action") + "?filter=" + $(e.currentTarget).find(".search-query").val();
 
  if($(e.currentTarget).find("#card_level_id").val() != undefined) {
    url = url + "&card_level_id=" + $(e.currentTarget).find("#card_level_id").val();
  }

  load_cardholders(url, $(".nav-tabs li.active a").data('tabname'));
  return false;
};

//Cardholder tab watcher
$(document).on('shown', 'a[data-toggle="tab"]',function (e) {
  var tabname = $(e.currentTarget).data('tabname');
  var url = "/venue/cardholders/" + tabname;
  load_cardholders(url, tabname);
});

var bind_pending_requests_cards_view = function() {
  $("#pending_requests_cards_form").submit(form_submitted);
  bind_filter();
};

var bind_approved_cards_view = function() {
  $("#approved_cards_form").submit(form_submitted);
  bind_filter();
  bind_card_level_select();
  bind_accordion_header();
};

var bind_pending_activation_cards_view = function() {
  $("#pending_activation_cards_form").submit(form_submitted);
  bind_filter();
  bind_card_level_select();
  bind_accordion_header();
};

var bind_filter = function() {
  $('.search-query + .btn').on('click.clear-search', function(e){
    if($(e.currentTarget).find("i").hasClass("icon-remove")) {
      $(e.currentTarget).parents('form').find('.search-query').val('');
    }
  });

  $('.search-query').on('keydown', function(e){
    $(e.currentTarget).next('.btn').off('click.clear-search').find('.icon-remove').removeClass('icon-remove').addClass('icon-search');
  });
};

var bind_card_level_select = function() {
  $('select#card_level_id').change(function(e){
    $(e.currentTarget).parents('form').submit();
  });
};
  
var bind_accordion_header = function() {
  $('.accordion-header').click(function(e) {
    var $header = $(e.currentTarget);
    $header.toggleClass('info');
    $header.siblings('.accordion-header').removeClass('info');
    var $body = $header.next('.accordion-body');
    $body.siblings('.accordion-body').addClass('hidden');
    $body.toggleClass('hidden').removeClass('success');
  });
};

bind_pending_requests_cards_view();


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
// Bulk Resent form /////////////////////////////////////////////////////////
$(function(){
  $('body').on('ajax:success', '.bulk-resend-onboarding-sms', function(e){
    alert('Onboarding SMS Sent');
  });
});
