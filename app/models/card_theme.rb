class CardTheme < ActiveRecord::Base
  belongs_to :venue

  validates :name,
    presence: true,
    uniqueness: { scope: :venue_id }

  mount_uploader :portrait_background, ImageUploader
  mount_uploader :landscape_background, ImageUploader

  def portrait_background_path
    portrait_background.cached? ? "/carrierwave/#{portrait_background.cache_name}" : portrait_background.url
  end

  def landscape_background_path
    landscape_background.cached? ? "/carrierwave/#{landscape_background.cache_name}" : landscape_background.url
  end
end
