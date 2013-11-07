$('#cardholder_photo').change(function() {
  var self = this;
  readImagePreviewToBackground(this, $('.photo-preview'));

  $('#PhotoReminderModal').modal().one('click','.btn',function(e){
    var $this = $(e.currentTarget);

    if ($this.is('[class*=retake]')){
      $(self).click();
    } else {
      var $elements = $(self).parents('form').find('input,textarea,button,select').not('[type="hidden"]')
      $elements.get($elements.index(self) + 1).focus();
    }
  });
});
