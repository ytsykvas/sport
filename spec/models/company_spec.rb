require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'associations' do
    it { should belong_to(:owner).class_name('User').with_foreign_key('owner_id') }
    it { should have_many(:users).dependent(:nullify) }
  end

  describe 'validations' do
    subject { create(:company) }

    it { should validate_presence_of(:name) }
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

      it 'is invalid when owner has manager role' do
        manager_company = create(:company)
        manager = create(:user, :manager, company: manager_company)
        new_company = build(:company, owner_user: manager)
        expect(new_company).not_to be_valid
        expect(new_company.errors[:owner]).to include("must have 'owner' role")
      end

      it 'allows updating persisted company with existing owner' do
        company = create(:company)
        company.name = 'Updated Company Name'
        expect(company).to be_valid
      end

      it 'validates owner role for new record' do
        customer = build(:user, :customer)
        company = build(:company, owner_user: customer)
        expect(company).not_to be_valid
      end
    end

    context 'name validation' do
      let(:company) { create(:company) }

      it 'is invalid without name' do
        company.name = nil
        expect(company).not_to be_valid
        expect(company.errors[:name]).to be_present
      end

      it 'is invalid with empty name' do
        company.name = ''
        expect(company).not_to be_valid
        expect(company.errors[:name]).to be_present
      end

      it 'allows duplicate names' do
        company1 = create(:company, name: 'Acme Corp')
        company2 = build(:company, name: 'Acme Corp')
        expect(company2).to be_valid
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

    it 'creates company with custom owner' do
      owner = build(:user, role: :owner, name: 'Custom Owner')
      company = create(:company, owner_user: owner)
      expect(company.owner.name).to eq('Custom Owner')
    end

    it 'creates company with employees trait' do
      company = create(:company, :with_employees)
      expect(company.users.where(role: :employee).count).to eq(3)
    end

    it 'creates company with managers trait' do
      company = create(:company, :with_managers)
      expect(company.users.where(role: :manager).count).to eq(2)
    end
  end

  describe 'dependent associations' do
    let(:company) { create(:company) }
    let!(:employee1) { create(:user, :employee, company: company) }
    let!(:employee2) { create(:user, :employee, company: company) }
    let!(:manager) { create(:user, :manager, company: company) }

    it 'nullifies all users when company is destroyed' do
      company.destroy

      expect(employee1.reload.company_id).to be_nil
      expect(employee2.reload.company_id).to be_nil
      expect(manager.reload.company_id).to be_nil
    end

    it 'does not delete users when company is destroyed' do
      employee_ids = [ employee1.id, employee2.id, manager.id ]

      expect { company.destroy }.not_to change { User.where(id: employee_ids).count }
    end

    it 'destroys company when owner is destroyed' do
      company_id = company.id
      owner = company.owner

      expect { owner.destroy }.to change { Company.exists?(company_id) }.from(true).to(false)
    end
  end

  describe 'owner relationship' do
    let(:company) { create(:company) }
    let(:owner) { company.owner }

    it 'has correct owner association' do
      expect(company.owner).to eq(owner)
      expect(owner.owned_company).to eq(company)
    end

    it 'owner can optionally be part of company users through company_id' do
      owner.company_id = company.id
      owner.save!
      expect(owner.company_id).to eq(company.id)
      expect(company.users).to include(owner)
    end

    it 'owner cannot be changed to non-owner user' do
      customer = create(:user, :customer)
      company.owner = customer
      expect(company).not_to be_valid
    end

    it 'owner can be changed to another owner role user' do
      new_owner = build(:user, role: :owner)
      company.owner = new_owner
      new_owner.owned_company = company
      expect(company).to be_valid
    end
  end

  describe 'users management' do
    let(:company) { create(:company) }

    it 'can add multiple employees to company' do
      employee1 = create(:user, :employee, company: company)
      employee2 = create(:user, :employee, company: company)

      expect(company.users).to include(employee1, employee2)
    end

    it 'can add multiple managers to company' do
      manager1 = create(:user, :manager, company: company)
      manager2 = create(:user, :manager, company: company)

      expect(company.users).to include(manager1, manager2)
    end

    it 'can have mixed employee and manager users' do
      employee = create(:user, :employee, company: company)
      manager = create(:user, :manager, company: company)

      expect(company.users).to include(employee, manager)
    end

    it 'owner can be included in users if company_id is set' do
      owner = company.owner
      owner.company_id = company.id
      owner.save!
      expect(company.users.reload).to include(owner)
    end

    it 'by default owner is not in users collection' do
      owner = company.owner
      expect(company.users).not_to include(owner)
      expect(owner.company_id).to be_nil
    end
  end
end
