$('#card_level_id').change(function() {
  $('#card_level_form').submit();
});

$('.accordion-header').click(function(e) {
  var header = $(e.currentTarget);
  header.toggleClass('info');
  header.siblings('.accordion-header').removeClass('info');
  var body = header.next('.accordion-body');
  body.siblings('.accordion-body').addClass('hidden');
  body.toggleClass('hidden').removeClass('success');
});

$('form.edit_card select').change(function(e) {
  var body = $(e.currentTarget).parents('.accordion-body');
  var header = body.prev('.accordion-header');

  body.addClass('warning');
  header.addClass('warning');
});

$('form.edit_card').bind("ajax:success", function(xhr,data) {
  var body = $(xhr.currentTarget).parents('.accordion-body');
  var header = body.prev('.accordion-header');

  body.removeClass('warning').addClass('success');
  header.removeClass('warning');

  header.find('.card-level').text(data.card_level.name);
  body.find('.card-level').text(data.card_level.name);
  body.find('.card-preview').removeClass(function(index, classes){
        return (classes.match(/\btheme-\S+/g) || []).join(' ');
      }).addClass('theme-' + data.card_level.theme);
});

$('form.edit_card').bind("ajax:error", function(xhr,data) {
  var body = $(xhr.currentTarget).parents('.accordion-body');
  var header = body.prev('.accordion-header');

  body.removeClass('warning').addClass('error');
});
