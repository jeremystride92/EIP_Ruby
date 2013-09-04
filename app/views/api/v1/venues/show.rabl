object :@venue
attributes :name, :time_zone
attribute phone: :tel_number
attribute sender_number: :sms_number

node :time_zone_offset do |venue|
  ActiveSupport::TimeZone[venue.time_zone || Time.zone.name].formatted_offset
end

node :logos do |venue|
  {
    full: venue.logo.url,
    mobile_large: venue.logo.mobile_large.url,
    mobile_small: venue.logo.mobile_small.url
  }
end
