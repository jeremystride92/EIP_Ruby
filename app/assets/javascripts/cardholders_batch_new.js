(function() {
  var fields_template = _.template('<fieldset class="row-fluid cardholder_fields" data-index="<%= index %>">\
  <div class="control-group tel required cardholders_phone_number span3">\
    <label class="tel required control-label" for="cardholders_<%= index %>_phone_number">\
      <abbr title="required">*</abbr> Phone number\
    </label>\
    <div class="controls">\
      <input class="string tel required" id="cardholders_<%= index %>_phone_number" name="cardholders[<%= index %>][phone_number]" pattern="\\d{10}" required="required" size="50" type="tel" />\
      <p class="help-block">10-digit number, digits only</p>\
    </div>\
  </div>\
  <div class="control-group string optional cardholders_first_name span3">\
    <label class="string optional control-label" for="cardholders_<%= index %>_first_name">First name</label>\
    <div class="controls">\
      <input class="string optional" id="cardholders_<%= index %>_first_name" name="cardholders[<%= index %>][first_name]" size="50" type="text" />\
    </div>\
  </div>\
  <div class="control-group string optional cardholders_last_name span3">\
    <label class="string optional control-label" for="cardholders_<%= index %>_last_name">Last name</label>\
      <div class="controls"><input class="string optional" id="cardholders_<%= index %>_last_name" name="cardholders[<%= index %>][last_name]" size="50" type="text">\
    </div>\
  </div>\
  <button class="btn btn-large btn-success pull-right button-add" id="issue_another" data-index="<%= index %>">\
    <i class="icon-plus"></i>\
  </button>\
</fieldset>');

  $('.batch_cardholders').delegate('#issue_another', 'click', function(e) {
    e.preventDefault();

    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $batch_area = $('.batch_cardholders');

    $button.attr('id', '')
      .removeClass('btn-success btn-large')
      .addClass('btn-danger button-remove')
      .find('i').removeClass('icon-plus').addClass('icon-minus');

    $batch_area.append(fields_template({ index: index + 1 }));
    $('#cardholders_' + (index + 1) + '_phone_number').focus();
  });

  $('.batch_cardholders').delegate('.button-remove', 'click', function(e) {
    e.preventDefault();
    var $button = $(e.currentTarget);
    var index = $button.data('index');
    var $fieldset = $('.cardholder_fields[data-index="' + index + '"]');

    $fieldset.remove();
  });

  $(function() {
    $('.batch_cardholders').append(fields_template({ index: 0 }));
  });
})();
