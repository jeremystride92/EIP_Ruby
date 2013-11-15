class CardLevelsPromotionalMessage < ActiveRecord::Base
  belongs_to :card_level
  belongs_to :promotional_message
end