namespace :eipid do
  desc "Update guest passes for all venues in current time zone"
  task :update_guest_passes_for_current_time_zone, [:run_time] => :environment do |t, args|
    run_time = (args[:run_time] || "4").to_i

    Rails.logger.info "Current time is #{Time.current.to_s :db}"
    Rails.logger.info "Updating guest passes for all venues where it's currently 0#{run_time}00 hours local"

    Venue.includes(card_levels: [:cards]).all.each do |venue|
      Time.use_zone(venue.time_zone) do
        next unless Time.current.hour == run_time
        Rails.logger.info "It's time to refresh passes at #{venue.name}."

        venue.set_all_card_level_guest_passes
      end
    end
  end
end
