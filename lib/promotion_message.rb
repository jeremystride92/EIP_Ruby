class PromotionMessage
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :message, :card_levels, :send_date_time

  def initialize(attributes = {})
    return if attributes.empty?

    self.message = attributes[:message]
    self.card_levels = attributes[:card_levels].reject &:blank?

    date_time_attrs = (1..5).map { |n| "send_date_time(#{n}i)" }
    year, month, day, hour, minute = attributes.values_at(*date_time_attrs).map &:to_i

    self.send_date_time = Time.zone.local year, month, day, hour, minute
  end

  def persisted?
    false
  end
end
