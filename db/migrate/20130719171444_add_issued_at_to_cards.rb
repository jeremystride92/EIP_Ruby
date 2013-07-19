class AddIssuedAtToCards < ActiveRecord::Migration
  def migrate(direction)
    super
    if direction == :up
      Card.reset_column_information
      Card.all.each do |card|
        card.issued_at = card.updated_at unless card.pending?
        card.save
      end
    end
  end
  def change
    add_column :cards, :issued_at, :datetime
  end
end
