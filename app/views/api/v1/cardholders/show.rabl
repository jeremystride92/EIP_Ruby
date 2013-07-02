object :@cardholder
attributes :id, :phone_number, :first_name, :last_name

node :photo do |cardholder|
  {
    full: cardholder.photo.url,
    mobile_large: cardholder.photo.mobile_large.url,
    mobile_small: cardholder.photo.mobile_small.url
  }
end

child :cards do
  extends 'api/v1/cards/show'
end
