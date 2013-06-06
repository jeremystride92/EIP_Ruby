object :@venue
attributes :name
node :logo do |venue|
  venue.logo.url
end
