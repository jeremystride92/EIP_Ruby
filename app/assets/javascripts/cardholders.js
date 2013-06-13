$('#card_level_id').change(function() {
  $('#card_level_form').submit();
});

$('.accordion-header').click(function(e) {
  var header = $(e.currentTarget);
  header.toggleClass('info');
  header.siblings('.accordion-header').removeClass('info');
  var body = header.next('.accordion-body');
  body.siblings('.accordion-body').addClass('hidden');
  body.toggleClass('hidden');
});
