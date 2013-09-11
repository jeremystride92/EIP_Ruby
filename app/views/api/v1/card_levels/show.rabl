object :@card_level
attributes :name

child :benefits do
  extends 'api/v1/benefits/show'
end

child :promotions do
  extends 'api/v1/promotions/show'
end

node :card_theme do |card_level|
  partial 'api/v1/card_themes/show', object: card_level.card_theme
end
