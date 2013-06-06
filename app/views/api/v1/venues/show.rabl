object :@venue
attributes :name
node :logos do |venue|
  {
    full: venue.logo.url,
    mobile_large: venue.logo.mobile_large.url,
    mobile_small: venue.logo.mobile_small.url
  }
end
