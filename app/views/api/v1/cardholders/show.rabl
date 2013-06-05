object :@cardholder
attributes :id, :phone_number, :first_name, :last_name, :photo
node :cards do |cardholder|
  cardholder.cards.map do |card|
    partial 'api/v1/cards/show', object: card
  end
end

