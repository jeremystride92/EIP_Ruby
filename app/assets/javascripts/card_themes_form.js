$('#card_theme_portrait_background').change(function() {
  readImagePreviewToBackground(this, $('.upload-preview.portrait'));
});

$('#card_theme_landscape_background').change(function() {
  readImagePreviewToBackground(this, $('.upload-preview.landscape'));
});
