$('form #promotion_image').change(function() {
  readImagePreview(this, $('#promotion-img'));
});

countCharacters($('#promotion_message_message'), $('.character-count'), 140);
