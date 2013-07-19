class Promotion < ActiveRecord::Base
  belongs_to :venue

  has_and_belongs_to_many :card_levels

  validates :title, presence: true
  validates :venue, presence: true

  mount_uploader :image, PromotionImageUploader

  include Expirable

  def image_path
    image.cached? ? "/carrierwave/#{image.cache_name}" : image.url
  end
end
