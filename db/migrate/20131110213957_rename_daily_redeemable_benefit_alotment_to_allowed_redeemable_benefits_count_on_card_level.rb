class RenameDailyRedeemableBenefitAlotmentToAllowedRedeemableBenefitsCountOnCardLevel < ActiveRecord::Migration
  def up
    rename_column :card_levels, :daily_redeemable_benefit_allotment, :allowed_redeemable_benefits_count
  end

  def down
    rename_column :card_levels, :allowed_redeemable_benefits_count, :daily_redeemable_benefit_allotment
  end
end
