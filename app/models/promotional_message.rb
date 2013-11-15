class PromotionalMessage < ActiveRecord::Base

  has_many :card_levels_promotional_messages
  has_many :card_levels, through: :card_levels_promotional_messages
  belongs_to :promotion

end
