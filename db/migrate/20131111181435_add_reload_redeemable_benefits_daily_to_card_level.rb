class AddReloadRedeemableBenefitsDailyToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :reload_redeemable_benefits_daily, :bool
  end
end
