class Promotion < ActiveRecord::Base
  belongs_to :venue

  has_and_belongs_to_many :card_levels, conditions: { deleted_at: nil }

  validates :title, presence: true
  validates :venue, presence: true

  mount_uploader :image, PromotionImageUploader

  include Expirable
  include Comparable

  def image_path
    image.cached? ? "/carrierwave/#{image.cache_name}" : image.url
  end

  def <=> other
    end_comparison = compare_end_dates(other)

    end_comparison.zero? ? compare_start_dates(other) : end_comparison
  end

  private

  def compare_end_dates(other)
    if self.end_date.nil?
      other.end_date.nil? ? 0 : 1;
    elsif other.end_date.nil?
      -1
    else
      self.end_date <=> other.end_date
    end
  end

  def compare_start_dates(other)
    if self.start_date.nil?
      other.start_date.nil? ? 0 : -1;
    elsif other.start_date.nil?
      1
    else
      self.start_date <=> other.start_date
    end
  end
end
