object :@venue
attributes :name
node :logos do |venue|
  {
    full: venue.logo.url,
    mobile_large: venue.logo.mobile_large.url,
    mobile_small: venue.logo.mobile_small.url
  }
end

node :promotions do |venue|
  [{
    date: Date.current,
    name: 'Live Music Night',
    description: '2 for 1 Bottle Service',
    image: venue.logo.mobile_large.url
  }]
end
