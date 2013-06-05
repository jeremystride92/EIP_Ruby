# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    #first_name { Faker::Name.first_name }
    #last_name { Faker::Name.last_name }
    #email { "#{first_name}.#{last_name}@#{Faker::Internet.domain_name}".downcase }
    email { Faker::Internet.email }
    password 'secret'
    password_confirmation { |u| u.password }
  end

  factory :cardholder do
    phone_number { Faker::PhoneNumber.short_phone_number }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    photo "photo.jpg"
  end

  factory :venue do
    name { Faker::Company.name }
    logo "logo.png"
  end

  factory :card_level do
    sequence(:name) { |i| %w{Silver Gold Platinum Black}.sample + i.to_s }
    venue
  end

  factory :card do
    card_level
    cardholder
  end
end
