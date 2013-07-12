object :@promotion

attributes :title, :description, :start_date, :end_date
attribute active?: :active

node :images do |promotion|
  {
    full: promotion.image.display.url,
    mobile_large: promotion.image.mobile_large.url,
    mobile_small: promotion.image.mobile_small.url
  } if promotion.image.present?
end
