# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password 'secret'
    password_confirmation { |u| u.password }

    factory :venue_owner do
      roles { [:venue_owner] }
      venue
    end

    factory :venue_manager do
      roles { [:venue_manager] }
      venue
    end
  end

  factory :cardholder do
    phone_number { Faker.numerify('#' * 10) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    photo "photo.jpg"
  end

  factory :venue do
    name { Faker::Company.name }
    logo "logo.png"
    phone { Faker.numerify('#' * 10) }
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
    issuer { create :venue_manager }
    status 'active'

    factory :inactive_card do
      status 'inactive'
    end
  end
end
