//= require temporary_card_batch_fields
//= require temporary_card_batch_benefit_fields

if ($('#batch_partner').val()) {
  var selectedPartnerId = $('#batch_partner').val();
  populateBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), partnerBenefits[selectedPartnerId].benefits);
  $('#batch_redeemable_benefit_allotment').val(partnerBenefits[selectedPartnerId].default_redeemable_benefit_allotment);
} else {
  $('.batch-benefits .batch-rows').empty();
}

$('#batch_partner').on('change', function() {
  var selectedPartnerId = $('#batch_partner').val();
  populateBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), partnerBenefits[selectedPartnerId].benefits);
  $('#batch_redeemable_benefit_allotment').val(partnerBenefits[selectedPartnerId].default_redeemable_benefit_allotment);
});

manageBatchRows('temporary_card_batch_fields', $('.batch-temporary-cards'), 'phone_number', {});
manageBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), 'description', { description: '' }, true);

