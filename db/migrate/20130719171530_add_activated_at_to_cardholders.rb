class AddActivatedAtToCardholders < ActiveRecord::Migration
  def migrate(direction)
    super
    if direction == :up
      Cardholder.reset_column_information
      Cardholder.all.each do |cardholder|
        cardholder.activated_at = cardholder.updated_at if cardholder.active?
        cardholder.save
      end
    end
  end
  def change
    add_column :cardholders, :activated_at, :datetime
  end
end
