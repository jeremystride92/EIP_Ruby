class CreateCardholders < ActiveRecord::Migration
  def change
    create_table :cardholders do |t|
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.string :photo

      t.timestamps
    end

    add_index :cardholders, :phone_number
  end
end
