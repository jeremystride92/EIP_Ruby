namespace :eipid do
  desc "Update redeemable benefits for all venues in current time zone"
  task :update_redeemable_benefits_for_current_time_zone, [:run_time] => :environment do |t, args|
    run_time = (args[:run_time] || "4").to_i

    Rails.logger.info "Current time is #{Time.current.to_s :db}"
    Rails.logger.info "Updating redeemable benefits for all venues where it's currently 0#{run_time}00 hours local"

    Venue.includes(card_levels: [:cards]).all.each do |venue|
      zone = ActiveSupport::TimeZone[venue.time_zone]
      next unless zone.now.hour == run_time

      Rails.logger.info "It's time to refresh passes at #{venue.name}."
      venue.set_all_card_level_redeemable_benefit_allotments
    end
  end
end
