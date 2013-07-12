PromotionMessage = Struct.new(:message, :card_levels) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def persisted?
    false
  end
end
