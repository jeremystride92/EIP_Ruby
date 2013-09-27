function isPortrait(degrees) {
  return (degrees % 180) == 0;
}

function handleOrientation(degrees) {
  if (isPortrait(degrees)) {
    $('.card-container').removeClass('hidden');
    $('#landscape-notice').addClass('hidden');
  } else {
    $('.card-container').addClass('hidden');
    $('#landscape-notice').removeClass('hidden');
  }
}

window.addEventListener('orientationchange', function() {
  handleOrientation(window.orientation);
}, false);

handleOrientation(window.orientation);
