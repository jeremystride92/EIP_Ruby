class RemoveBenefitsFromCardLevel < ActiveRecord::Migration
  def up
    CardLevel.all.each do |card_level|
      card_level[:benefits].each do |benefit|
        Benefit.create! description: benefit, start_date: nil, end_date: nil, beneficiary: card_level
      end
    end

    remove_column :card_levels, :benefits
  end

  def down
    add_column :card_levels, :benefits, :text

    CardLevel.includes(:benefits).all.each do |card_level|
      card_level[:benefits] = card_level.benefits.map(&:description)
      card_level.save!
    end
  end
end
