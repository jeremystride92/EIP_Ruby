object :@card

node :card_level do |card|
  partial 'api/v1/card_levels/show', object: card.card_level
end

node :venue do |card|
  partial 'api/v1/venues/show', object: card.venue
end

attributes :guest_count, :status
