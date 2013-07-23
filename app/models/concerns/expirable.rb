module Expirable
  extend ActiveSupport::Concern

  included do
    before_validation :merge_datetime_fields

    # Define the /(start|end)_(date|time)_field(=?)/ methods
    %w(start end).each do |terminus|
      method_name = "#{terminus}_date"

      define_method "#{terminus}_date_field" do
        send(method_name).to_date.to_s if send(method_name)
      end

      define_method "#{terminus}_date_field=" do |value|
        send("#{terminus}_date_will_change!") unless send("#{terminus}_date_changed?")
        instance_variable_set("@#{terminus}_date_field", value)
      end

      define_method "#{terminus}_time_field" do
        send(method_name).to_s(:time) if send(method_name)
      end

      define_method "#{terminus}_time_field=" do |value|
        send("#{terminus}_date_will_change!") unless send("#{terminus}_date_changed?")
        instance_variable_set("@#{terminus}_time_field", value)
      end
    end

    def merge_datetime_fields
      # Only set the attributes if data was passed in from the form, hence the trailing `if`s.
      self.start_date = (@start_date_field.present?  ? "#{@start_date_field} #{@start_time_field}" : nil) if @start_date_field
      self.end_date = (@end_date_field.present? ? "#{@end_date_field} #{time_or_eod @end_time_field}" : nil) if @end_date_field
    end

    def active_in_range?(starts, ends)
      starts_before_end = self.start_date.nil? || self.start_date < ends
      ends_after_start = self.end_date.nil? || self.end_date > starts

      starts_before_end && ends_after_start
    end

    def inactive?(now = Time.zone.now)
      future?(now) || past?(now)
    end

    def active?(now = Time.zone.now)
      !inactive?(now)
    end

    def future?(now = Time.zone.now)
      self.start_date.present? && self.start_date > now
    end

    def past?(now = Time.zone.now)
      self.end_date.present? && self.end_date < now
    end

    def permanent?
      start_date.nil? && end_date.nil?
    end

    def temporary?
      !permanent?
    end

    private

    def time_or_eod(time)
      time.present? ? time : '23:59:59'
    end
  end
end
