class DropRedeemableBenefitsAllotmentFromCard < ActiveRecord::Migration
  def up
    remove_column :cards, :redeemable_benefit_allotment
  end

  def down
    add_column :cards, :redeemable_benefit_allotment, :integer
  end
end
