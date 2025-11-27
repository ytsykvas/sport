FactoryBot.define do
  factory :company do
    name { Faker::Company.name }

    # Build owner separately and set up the relationship in callback
    transient do
      owner_user { nil }
    end

    after(:build) do |company, evaluator|
      # Create owner user if not provided
      owner_user = evaluator.owner_user || FactoryBot.build(:user, role: :owner)
      company.owner = owner_user
      # Set inverse association so validation passes
      # Only set if user is not persisted (to avoid issues with existing employee users)
      if !owner_user.persisted?
        owner_user.owned_company = company
      end
    end

    trait :with_employees do
      after(:create) do |company|
        create_list(:user, 3, :employee, company: company)
      end
    end

    trait :with_managers do
      after(:create) do |company|
        create_list(:user, 2, :manager, company: company)
      end
    end

    trait :tech_company do
      name { "#{Faker::Company.name} #{[ 'Inc.', 'LLC', 'Corp.', 'Tech' ].sample}" }
    end

    trait :with_full_team do
      after(:create) do |company|
        create_list(:user, 5, :employee, company: company)
        create_list(:user, 2, :manager, company: company)
      end
    end
  end
end
