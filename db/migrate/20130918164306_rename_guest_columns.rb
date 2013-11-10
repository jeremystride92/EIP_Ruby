class RenameGuestColumns < ActiveRecord::Migration
  def change
    rename_column :card_levels, :daily_guest_pass_count, :allowed_redeemable_benefits_count
    rename_column :cards, :guest_count, :redeemable_benefit_allotment

    rename_column :partners, :default_guest_count, :default_redeemable_benefit_allotment
    rename_column :temporary_cards, :guest_count, :redeemable_benefit_allotment

    rename_table :guest_passes, :redeemable_benefits
  end
end
