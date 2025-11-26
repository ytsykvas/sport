FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :customer }

    trait :admin do
      role { :admin }
    end

    trait :customer do
      role { :customer }
    end

    trait :owner do
      role { :owner }
      association :company, factory: :company, strategy: :build
    end

    trait :employee do
      role { :employee }
      association :company
    end

    trait :manager do
      role { :manager }
      association :company
    end

    trait :with_company do
      association :company
    end
  end
end
