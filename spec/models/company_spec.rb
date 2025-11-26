require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { should belong_to(:owner).class_name('User').with_foreign_key('owner_id') }
    it { should have_many(:users).dependent(:nullify) }
  end

  describe 'validations' do
    subject { create(:company) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:owner) }

    context 'owner role validation' do
      it 'is valid when owner has owner role' do
        owner = build(:user, role: :owner)
        company = build(:company, owner_user: owner)
        expect(company).to be_valid
      end

      it 'is invalid when owner does not have owner role' do
        non_owner = build(:user, :customer)
        company = build(:company, owner_user: non_owner)
        expect(company).not_to be_valid
        expect(company.errors[:owner]).to include("must have 'owner' role")
      end

      it 'is invalid when owner has admin role' do
        admin = build(:user, :admin)
        company = build(:company, owner_user: admin)
        expect(company).not_to be_valid
        expect(company.errors[:owner]).to include("must have 'owner' role")
      end

      it 'is invalid when owner has employee role' do
        employee_company = create(:company)
        employee = create(:user, :employee, company: employee_company)
        new_company = build(:company, owner_user: employee)
        expect(new_company).not_to be_valid
        expect(new_company.errors[:owner]).to include("must have 'owner' role")
      end
    end
  end

  describe 'factory' do
    it 'has valid factory' do
      company = build(:company)
      expect(company).to be_valid
    end

    it 'creates owner with owner role' do
      company = create(:company)
      expect(company.owner.owner?).to be true
    end
  end

  describe 'dependent associations' do
    it 'nullifies users when company is destroyed' do
      company = create(:company)
      employee = create(:user, :employee, company: company)

      expect { company.destroy }.to change { employee.reload.company_id }.to(nil)
    end
  end

  describe 'uniqueness' do
    it 'does not allow duplicate company names' do
      create(:company, name: 'Unique Company')
      duplicate_company = build(:company, name: 'Unique Company')
      expect(duplicate_company).not_to be_valid
    end
  end
end
