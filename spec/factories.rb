# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password 'secret'
    password_confirmation { |u| u.password }
    roles { [:venue_manager] }

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
    password '1234'
    password_confirmation { |u| u.password }
    status 'active'

    factory :pending_cardholder do
      status 'pending'
      first_name nil
      last_name nil
    end
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
    time_zone "Mountain Time (US & Canada)"
  end

  factory :card_level do
    theme { CardLevel::THEMES.sample }
    sequence(:name) { |i| theme.titleize + i.to_s }
    venue
    daily_guest_pass_count { rand(4) + 1 }

    factory :card_level_with_benefits do
      after :create do |card_level, evaluator|
        FactoryGirl.create_list(:benefit, 3, beneficary: card_level)
      end
    end
  end

  factory :card do
    card_level
    cardholder
    status 'active'
    guest_count 3
    association :issuer, factory: :venue_manager

    factory :inactive_card do
      status 'inactive'
    end
  end

  factory :benefit do
    description "Get free stuff"
    start_date nil
    end_date nil
    association :beneficiary, factory: :card_level
  end

  factory :guest_pass do
    start_date nil
    end_date nil
    card
  end

  factory :promotion do
    title { Faker::DizzleIpsum.words(2) }
    start_date nil
    end_date nil
    image "promotion.png"
    venue

    trait :description do
      description { Faker:Lorem.paragraph }
    end
  end
end
