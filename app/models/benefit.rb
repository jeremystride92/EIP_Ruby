class Benefit < ActiveRecord::Base
  belongs_to :beneficiary, polymorphic: true

  validates :description, presence: true
  validates :beneficiary, presence: true, unless: Proc.new { |benefit| benefit.beneficiary && benefit.beneficiary.new_record? }

  before_validation :merge_datetime_fields

  def start_date_field
    start_date.to_date.to_s if start_date
  end

  def start_time_field
    start_date.to_s(:time) if start_date
  end

  def end_date_field
    end_date.to_date.to_s if end_date
  end

  def end_time_field
    end_date.to_s(:time) if end_date
  end

  def start_date_field=(value)
    start_date_will_change! unless start_date_changed?
    @start_date_field = value
  end

  def start_time_field=(value)
    start_date_will_change! unless start_date_changed?
    @start_time_field = value
  end

  def end_date_field=(value)
    end_date_will_change! unless end_date_changed?
    @end_date_field = value
  end

  def end_time_field=(value)
    end_date_will_change! unless end_date_changed?
    @end_time_field = value
  end

  def merge_datetime_fields
    # Only set the attributes if data was passed in from the form, hence the trailing `if`s.
    self.start_date = (@start_date_field.present?  ? "#{@start_date_field} #{@start_time_field}" : nil) if @start_date_field
    self.end_date = (@end_date_field.present? ? "#{@end_date_field} #{@end_time_field}" : nil) if @end_date_field
  end
end
