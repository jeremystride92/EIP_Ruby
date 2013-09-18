class AddRedeemableBenefitNameToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :redeemable_benefit_name, :string
  end
end
