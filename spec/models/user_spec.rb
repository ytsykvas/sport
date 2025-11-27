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

      it 'is invalid for owner without company or owned_company' do
        user = build(:user, role: :owner, company: nil)
        expect(user).not_to be_valid
        expect(user.errors[:company]).to include("must be present for owner role")
      end

      it 'is valid for owner with owned_company' do
        user = build(:user, role: :owner, company: nil)
        company = build(:company, owner_user: user)
        user.owned_company = company
        expect(user).to be_valid
      end

      it 'is valid for owner with company_id' do
        company = create(:company)
        user = build(:user, role: :owner, company: company)
        expect(user).to be_valid
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

    context 'owner can have only one company' do
      it 'is valid when owner has only owned_company without company_id' do
        company = create(:company)
        owner = company.owner
        expect(owner).to be_valid
        expect(owner.owned_company).to eq(company)
      end

      it 'is invalid when owner tries to set different company_id from owned_company' do
        company = create(:company)
        owner = company.owner
        owner.company_id = company.id
        owner.save!

        other_company = create(:company)
        owner.company_id = other_company.id
        expect(owner).not_to be_valid
        expect(owner.errors[:base]).to include("Owner can have only one company")
      end

      it 'is valid when owner company_id matches owned_company id' do
        company = create(:company)
        owner = company.owner
        owner.company_id = company.id
        expect(owner).to be_valid
      end

      it 'is valid for new owner without persisted owned_company' do
        new_owner = build(:user, role: :owner, company: nil)
        new_company = build(:company, owner_user: new_owner)
        new_owner.owned_company = new_company
        expect(new_owner).to be_valid
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

  describe 'factory' do
    it 'creates valid user with default customer role' do
      user = create(:user)
      expect(user).to be_valid
      expect(user.customer?).to be true
    end

    it 'creates valid admin user' do
      user = create(:user, :admin)
      expect(user).to be_valid
      expect(user.admin?).to be true
    end

    it 'creates valid employee with company' do
      user = create(:user, :employee)
      expect(user).to be_valid
      expect(user.employee?).to be true
      expect(user.company).to be_present
    end

    it 'creates valid manager with company' do
      user = create(:user, :manager)
      expect(user).to be_valid
      expect(user.manager?).to be true
      expect(user.company).to be_present
    end
  end

  describe 'owned company relationship' do
    let(:company) { create(:company) }
    let(:owner) { company.owner }

    it 'destroys owned_company when owner is destroyed' do
      company_id = company.id
      expect { owner.destroy }.to change { Company.exists?(company_id) }.from(true).to(false)
    end

    it 'owner is linked to owned_company' do
      expect(owner.owned_company).to eq(company)
    end

    it 'owner can optionally set company_id to owned_company' do
      owner.company_id = company.id
      owner.save!
      expect(owner.company).to eq(company)
    end
  end

  describe 'company relationship for employees' do
    let(:company) { create(:company) }
    let!(:employee) { create(:user, :employee, company: company) }

    it 'can have multiple employees in a company' do
      another_employee = create(:user, :employee, company: company)
      expect(company.users).to include(employee, another_employee)
    end

    it 'nullifies company_id when company is destroyed' do
      company.destroy
      expect(employee.reload.company_id).to be_nil
    end
  end
end
