function hideAddressBar() {
  setTimeout(function(){
    window.scrollTo(0, 1);
  }, 0);
}

function setBackgroundImage(orientation) {
  $('.card-container').css('background-image', 'url(' + themeBackgrounds[orientation] + ')');
}

$(function() {
  window.addEventListener("orientationchange", function() {
    switch(window.orientation) {
      case 0:
      case 180:
        $('.card-container').removeClass('landscape').addClass('portrait');
        setBackgroundImage('portrait');
        break;
      case 90:
      case -90:
        $('.card-container').addClass('landscape').removeClass('portrait');
        setBackgroundImage('landscape');
        hideAddressBar();
        break;
    };


  }, false);

  if (window.orientation % 180) {
    $('.card-container').addClass('landscape');
    setBackgroundImage('landscape');
    hideAddressBar();
  } else {
    $('.card-container').addClass('portrait');
    setBackgroundImage('portrait');
  }
});
