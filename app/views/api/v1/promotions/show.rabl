object :@promotion

attributes :title, :description, :start_date, :end_date
attribute active?: :active

node(:images, if: lambda { |promotion| promotion.image.present? }) do |promotion|
  {
    full: promotion.image.url,
    mobile_large: promotion.image.mobile_large.url,
    mobile_small: promotion.image.mobile_small.url
  }
end
