$('#cardholder_photo').change(function(e) {
  var self = this;

  function confirmRetake(e){
    var $this = $(e.currentTarget);

    if ($this.is('[class*=retake]')){
      $(self).click();
    } else {
      var $elements = $(self).parents('form').find('input,textarea,button,select').not('[type="hidden"]');
      $elements.get($elements.index(self) + 1).focus();
    }
  }

  readImagePreviewToBackground(this, $('.photo-preview'));

  var files = e.currentTarget.files;
  $(e.currentTarget).parent().find('.file_wrapper_file_name').text(" (Uploaded File: " + _.first(files).name + ")");

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
  
});

if(! /Android\ 2/.test(navigator.userAgent)){
  var $upload_button = $('<a class="file_wrapper btn">Upload Photo</a><span class="file_wrapper_file_name"></span>');
  $('input[type=file]').addClass('hidden').before($upload_button);
}

$('body').on('click','.file_wrapper',function(e){
  $(e.currentTarget).parent().find('input[type=file]')[0].click();
});
