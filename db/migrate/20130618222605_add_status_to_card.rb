class AddStatusToCard < ActiveRecord::Migration
  def up
    add_column :cards, :status, :string

    Card.all.each do |card|
      card.update_attributes(status: 'active')
    end
  end

  def down
    remove_column :cards, :status
  end

end
