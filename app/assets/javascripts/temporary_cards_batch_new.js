//= require temporary_card_batch_fields
//= require temporary_card_batch_benefit_fields

if ($('.records').length) {
  var records = _.map($('.records').data('records'), function(r) { return JSON.parse(r); });
  populateBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), records);
}

manageBatchRows('temporary_card_batch_fields', $('.batch-temporary-cards'), 'phone_number', {});
manageBatchRows('temporary_card_batch_benefit_fields', $('.batch-benefits'), 'description', { description: '' });

