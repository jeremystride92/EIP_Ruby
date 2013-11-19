class AddSourceToCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :source, :string
  end
end
