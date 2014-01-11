object :@card_level
attributes :name

child :benefits do
  extends 'api/v1/benefits/show'
end

child :promotions do
  extends 'api/v1/promotions/show'
end

if card_level.card_theme.present? 
  node :card_theme do |card_level|
    partial 'api/v1/card_themes/show', object: card_level.card_theme
  end
end

node :redeemable_benefit_name do |card_level|
  {
    singular: card_level.redeemable_benefit_title,
    plural: card_level.redeemable_benefit_title.pluralize
  }
end
