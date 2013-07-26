function hideAddressBar() {
  setTimeout(function(){
    window.scrollTo(0, 1);
  }, 0);
}

$(function() {
  window.addEventListener("orientationchange", function() {
    switch(window.orientation) {
      case 0:
      case 180:
        $('.card-container').removeClass('landscape').addClass('portrait');
        break;
      case 90:
      case -90:
        $('.card-container').addClass('landscape').removeClass('portrait');
        hideAddressBar();
        break;
    };
  }, false);

  if (window.orientation % 180) {
    $('.card-container').addClass('landscape');
    hideAddressBar();
  } else {
    $('.card-container').addClass('portrait');
  }
});
