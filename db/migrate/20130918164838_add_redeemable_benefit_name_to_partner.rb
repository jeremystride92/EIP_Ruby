class AddRedeemableBenefitNameToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :redeemable_benefit_name, :string
  end
end
