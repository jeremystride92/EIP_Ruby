object :@promotion

attributes :title, :description, :start_date, :end_date
node :description_auto_linked do |promotion|
  auto_link promotion.description, :html => { :target => '_blank', "data-bypass" => true }
end

attribute active?: :active
node :short_url do |promotion|
  $short_url_cache.shorten(public_promotion_url(subdomain: promotion.venue.vanity_slug, id: promotion.id))
end

node :images do |promotion|
  {
    full: promotion.image.display.url,
    mobile_large: promotion.image.mobile_large.url,
    mobile_small: promotion.image.mobile_small.url
  } if promotion.image.present?
end
