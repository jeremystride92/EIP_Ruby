jQuery(function() {
  $("a[rel=popover]").popover();
  $(".tooltip").tooltip();
  $("a[rel=tooltip]").tooltip();
});

function countCharacters($input, $label, maxCharCount) {
  $input.keyup(function() {
    var count = $input.val().length;
    $label.text('(' + (maxCharCount - count) + ' characters remaining)');
  });
}
