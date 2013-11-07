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

  desc "Migrate Data for CardLevel redeemable benefits to models from property"
  task :migrate_redeemable_benefits, [:run_time] => :environment do |t, args|

    Card.transaction do
      unmigrated_cards = Card.where("redeemable_benefit_allotment > ?", 0)

      unmigrated_cards.each do |card|

        level_allotment = card.card_level.daily_redeemable_benefit_allotment 
        card_allotment = card.redeemable_benefit_allotment

        used_benefits = level_allotment - card_allotment
        used_benefits = used_benefits < 0 ? level_allotment : used_benefits

        benefits = (1..level_allotment).map do |n|
          card.redeemable_benefits.build({source: :card_level})
        end

        benefits.take(used_benefits).each do |benefit|
          benefit.redeem
        end

        card.redeemable_benefit_allotment = 0
        card.save

      end
    end

  end

end
