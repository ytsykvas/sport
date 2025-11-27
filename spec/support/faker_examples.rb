# frozen_string_literal: true

# Examples of Faker usage in tests
# This file is for reference only and is not loaded by RSpec

# ==============================================================================
# Basic User Data
# ==============================================================================

# Names
Faker::Name.name                    # => "Christophe Bartell"
Faker::Name.first_name              # => "Kaci"
Faker::Name.last_name               # => "Ernser"
Faker::Name.name_with_middle        # => "Aditya Elton Douglas"

# Email
Faker::Internet.email               # => "eliza@mann.net"
Faker::Internet.safe_email          # => "christelle@example.org"
Faker::Internet.unique.email        # => Unique email for each call

# Password
Faker::Internet.password            # => "uw6Gc3KE3";
Faker::Internet.password(min_length: 8, max_length: 20)  # => "aZ1!bY2@cX3#"

# Phone
Faker::PhoneNumber.phone_number     # => "397-123-7849"
Faker::PhoneNumber.cell_phone       # => "123-456-7890"

# ==============================================================================
# Company Data
# ==============================================================================

Faker::Company.name                 # => "Hirthe-Ritchie"
Faker::Company.industry             # => "Food & Beverages"
Faker::Company.catch_phrase         # => "Monitored regional contingency"
Faker::Company.bs                   # => "empower efficient channels"

# ==============================================================================
# Address & Location
# ==============================================================================

Faker::Address.city                 # => "Imogeneborough"
Faker::Address.street_address       # => "282 Kevin Brook"
Faker::Address.country              # => "French Guiana"
Faker::Address.postcode             # => "58517"

# ==============================================================================
# Numbers & Dates
# ==============================================================================

Faker::Number.number(digits: 10)   # => 1234567890
Faker::Number.decimal(l_digits: 2, r_digits: 2)  # => 11.88
Faker::Number.between(from: 1, to: 100)  # => Random number between 1 and 100

Faker::Date.birthday(min_age: 18, max_age: 65)  # => Date object
Faker::Date.between(from: 1.year.ago, to: Date.today)  # => Random date
Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)  # => Random time

# ==============================================================================
# Lorem & Text
# ==============================================================================

Faker::Lorem.word                   # => "repellendus"
Faker::Lorem.words(number: 3)       # => ["dolores", "adipisci", "nesciunt"]
Faker::Lorem.sentence               # => "Dolore illum animi et neque accusantium."
Faker::Lorem.paragraph              # => Long text paragraph

# ==============================================================================
# Internet & Technology
# ==============================================================================

Faker::Internet.url                 # => "http://thiel.com/chauncey_simonis"
Faker::Internet.domain_name         # => "effertz.info"
Faker::Internet.username            # => "alex"
Faker::Internet.slug                # => "pariatur_laudantium"

# ==============================================================================
# File & Image
# ==============================================================================

Faker::File.file_name               # => "nesciunt.mp3"
Faker::File.extension               # => "mp3"
Faker::File.mime_type               # => "application/pdf"

# ==============================================================================
# Sports (useful for your sport app!)
# ==============================================================================

Faker::Sport.sport                  # => "Football"
Faker::Team.name                    # => "Texas Wildcats"
Faker::Team.sport                   # => "basketball"

# ==============================================================================
# Unique Values
# ==============================================================================

# Use .unique to ensure no duplicates across test suite
Faker::Internet.unique.email        # Always unique
Faker::PhoneNumber.unique.phone_number  # Always unique

# Clear unique generator (already configured in rails_helper):
# Faker::UniqueGenerator.clear

# ==============================================================================
# Locales
# ==============================================================================

# Change locale temporarily
Faker::Config.locale = :uk          # Ukrainian
Faker::Name.name                    # => "Олександр Шевченко"

Faker::Config.locale = :en          # Back to English
Faker::Name.name                    # => "John Doe"

# ==============================================================================
# Usage in Factories
# ==============================================================================

# Example:
# factory :user do
#   name { Faker::Name.name }
#   email { Faker::Internet.unique.email }
#   phone { Faker::PhoneNumber.phone_number }
#   company { Faker::Company.name }
# end

# Example with custom data:
# factory :athlete do
#   name { Faker::Name.name }
#   sport { Faker::Sport.sport }
#   team { Faker::Team.name }
#   email { Faker::Internet.unique.email }
# end

# ==============================================================================
# Usage in Tests
# ==============================================================================

# Example:
# it "creates user with random data" do
#   user = create(:user,
#     name: Faker::Name.name,
#     bio: Faker::Lorem.paragraph
#   )
#   expect(user).to be_valid
# end
