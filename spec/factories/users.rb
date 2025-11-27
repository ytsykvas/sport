FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8, max_length: 20) }
    password_confirmation { password }
    role { :customer }

    trait :admin do
      role { :admin }
      name { "Admin #{Faker::Name.name}" }
    end

    trait :customer do
      role { :customer }
      name { "Customer #{Faker::Name.name}" }
    end

    trait :owner do
      role { :owner }
      name { "Owner #{Faker::Name.name}" }
      association :company, factory: :company, strategy: :build
    end

    trait :employee do
      role { :employee }
      name { "Employee #{Faker::Name.name}" }
      association :company
    end

    trait :manager do
      role { :manager }
      name { "Manager #{Faker::Name.name}" }
      association :company
    end

    trait :with_company do
      association :company
    end
  end
end
