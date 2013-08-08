//= require temporary_card_batch_benefit_fields

if ($('.records').length) {
  var records = $('.records').data('records');
  populateBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), records);
}

manageBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), 'description', { description : '' });
