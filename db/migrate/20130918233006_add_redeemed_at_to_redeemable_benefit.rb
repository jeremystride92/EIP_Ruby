class AddRedeemedAtToRedeemableBenefit < ActiveRecord::Migration
  def change
    add_column :redeemable_benefits, :redeemed_at, :datetime
  end
end
