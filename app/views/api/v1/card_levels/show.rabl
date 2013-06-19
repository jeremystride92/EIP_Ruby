object :@card_level
attributes :name, :theme

node :benefits do |card_level|
  card_level.benefits.map do |benefit|
    partial 'api/v1/benefits/show', object: benefit
  end
end
