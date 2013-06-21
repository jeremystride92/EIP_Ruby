object :@cardholder
attributes :id, :phone_number, :first_name, :last_name, :photo

child :cards do
  extends 'api/v1/cards/show'
end
