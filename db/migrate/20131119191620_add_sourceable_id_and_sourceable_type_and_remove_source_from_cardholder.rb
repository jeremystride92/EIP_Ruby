class AddSourceableIdAndSourceableTypeAndRemoveSourceFromCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :sourceable_type, :string
    add_column :cardholders, :sourceable_id, :integer
    remove_column :cardholders, :source
  end
end
