# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    #first_name { Faker::Name.first_name }
    #last_name { Faker::Name.last_name }
    #email { "#{first_name}.#{last_name}@#{Faker::Internet.domain_name}".downcase }
    email { Faker::Internet.email }
    password 'secret'
    password_confirmation { |u| u.password }

    factory :admin do
      roles { [:admin] }
    end

    factory :venue_owner do
      roles { [:venue_owner] }
    end

    factory :venue_manager do
      roles { [:venue_manager] }
    end
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
    phone { Faker::PhoneNumber.short_phone_number }
    location { Faker::Address.neighborhood }
    address1 { Faker::Address.street_address }
    address2 { rand(3).zero? ? Faker::Address.secondary_address : nil }
    website { Faker::Internet.http_url }
    vanity_slug { rand(1).zero? ? name.parameterize : nil }
  end

  factory :card_level do
    theme { CardLevel::THEMES.sample }
    sequence(:name) { |i| theme.titleize + i.to_s }
    venue
    benefits { ['Free drinks!', 'Private table for 12!'] }

  end

  factory :card do
    card_level
    cardholder
    guest_count { 3 }
  end
end
