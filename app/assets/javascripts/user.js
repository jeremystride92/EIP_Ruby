$("[name='user[roles]']").on('change', function(e){
  var $this = $(e.currentTarget);
  var partner = $this.parents('form').find('[name="user[partner_id]"]');
  var partner_control_group = partner.parents('.control-group');

  if($this.val() === "venue_partner"){
    partner_control_group.removeClass('hidden');
    // partner.attr('required','required');
  } else {
    partner_control_group.addClass('hidden');
    // partner.attr('required',null);
  }
});