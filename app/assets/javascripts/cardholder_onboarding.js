function confirmRetake(e){
  var $this = $(e.currentTarget);

  if ($this.is('[class*=retake]')){
    $(self).click();
  } else {
    var $elements = $(self).parents('form').find('input,textarea,button,select').not('[type="hidden"]')
    $elements.get($elements.index(self) + 1).focus();
  }
}

$('#cardholder_photo').change(function() {
  var self = this;
  readImagePreviewToBackground(this, $('.photo-preview'));

  $('#PhotoReminderModal').modal().one('click','.btn',confirmRetake);
});

$('.simple_form.edit_cardholder').on('submit',function(e){
  var complete_submit = true;
  
  $('#cardholder_photo[required]').each(function(v){
    
    if (! $(v).val()){
      $('#PhotoValidationModal').modal().one(confirmRetake);
      complete_submit = false;
    }
  });
  
  if (! complete_submit) {
    return false;
  }
  
})

