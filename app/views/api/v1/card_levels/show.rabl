object :@card_level
attributes :name, :theme

child :benefits do
  extends 'api/v1/benefits/show'
end

child :promotions do
  extends 'api/v1/promotions/show'
end
