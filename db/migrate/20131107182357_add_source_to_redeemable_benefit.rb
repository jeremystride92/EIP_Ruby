class AddSourceToRedeemableBenefit < ActiveRecord::Migration
  def change
    add_column :redeemable_benefits, :source, :string
  end
end
