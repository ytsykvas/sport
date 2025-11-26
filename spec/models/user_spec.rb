require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:company).optional }
    it { should have_one(:owned_company).class_name('Company').with_foreign_key('owner_id').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }

    it { should define_enum_for(:role).with_values(admin: 0, customer: 1, owner: 2, employee: 3, manager: 4) }

    context 'company presence for specific roles' do
      it 'is valid for customer without company' do
        user = build(:user, :customer, company: nil)
        expect(user).to be_valid
      end

      it 'is valid for admin without company' do
        user = build(:user, :admin, company: nil)
        expect(user).to be_valid
      end

      it 'is invalid for owner without company' do
        user = build(:user, role: :owner, company: nil)
        expect(user).not_to be_valid
        expect(user.errors[:company]).to include("must be present for owner role")
      end

      it 'is invalid for employee without company' do
        user = build(:user, role: :employee, company: nil)
        expect(user).not_to be_valid
        expect(user.errors[:company]).to include("must be present for employee role")
      end

      it 'is invalid for manager without company' do
        user = build(:user, role: :manager, company: nil)
        expect(user).not_to be_valid
        expect(user.errors[:company]).to include("must be present for manager role")
      end
    end
  end

  describe 'role enum' do
    it 'allows setting role as admin' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end

    it 'allows setting role as customer' do
      user = create(:user, :customer)
      expect(user.customer?).to be true
    end

    it 'allows setting role as owner' do
      company = create(:company)
      user = create(:user, role: :owner, company: company)
      expect(user.owner?).to be true
    end

    it 'allows setting role as employee' do
      user = create(:user, :employee)
      expect(user.employee?).to be true
    end

    it 'allows setting role as manager' do
      user = create(:user, :manager)
      expect(user.manager?).to be true
    end
  end

  describe 'devise modules' do
    it 'has valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'requires password for new users' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end

    it 'requires valid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
    end

    it 'requires unique email' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      expect(duplicate_user).not_to be_valid
    end
  end
end
