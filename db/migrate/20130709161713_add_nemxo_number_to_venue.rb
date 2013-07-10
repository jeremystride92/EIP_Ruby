class AddNemxoNumberToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :nexmo_number, :string
  end
end
