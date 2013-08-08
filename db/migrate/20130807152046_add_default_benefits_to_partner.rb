class AddDefaultBenefitsToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :default_guest_count, :integer
    add_column :partners, :default_benefits, :text
  end
end
