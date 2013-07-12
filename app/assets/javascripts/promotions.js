$('form #promotion_image').change(function() {
  readImagePreview(this, $('#promotion-img'));
});

$('#promotion_message_message').keyup(function() {
  var count = $('#promotion_message_message').val().length;
  $('.character-count').text('(' + (140 - count) + ' characters remaining)');
});
