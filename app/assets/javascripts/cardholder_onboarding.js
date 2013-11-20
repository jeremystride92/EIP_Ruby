$('#cardholder_photo').change(function() {
  var self = this;

  function confirmRetake(e){
    var $this = $(e.currentTarget);

    if ($this.is('[class*=retake]')){
      $(self).click();
    } else {
      var $elements = $(self).parents('form').find('input,textarea,button,select').not('[type="hidden"]')
      $elements.get($elements.index(self) + 1).focus();
    }
  }

  readImagePreviewToBackground(this, $('.photo-preview'));

  $('#PhotoReminderModal').modal().one('click','.btn',confirmRetake);
});

$('.simple_form.edit_cardholder').on('submit',function(e){
  var complete_submit = true;
  
  $('#cardholder_photo[required]').each(function(i,v){
    
    if (! $(v).val()){
      $('#PhotoValidationModal').modal().one(confirmRetake);
      complete_submit = false;
    }
  });
  
  if (! complete_submit) {
    return false;
  }
  
})

$('input[type=file]').addClass('hidden').before('<a class="file_wrapper btn">Upload Photo</a><span class="file_wrapper_file_name"></span>').on('change',function(e){
  e.stopPropagation();
  e.preventDefault();

  var files = e.currentTarget.files;

  $(e.currentTarget).parent().find('.file_wrapper_file_name').text(" (Uploaded File: " + _.first(files).name + ")");
});

$('body').on('click','.file_wrapper',function(e){
  $(e.currentTarget).parent().find('input[type=file]')[0].click();
});