# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Crm::CompanyPolicy, type: :policy do
  subject { described_class.new(user, record) }

  describe '#index?' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, role: :owner) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end
  end

  describe '#show?' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.show?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, role: :owner) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.show?).to be false
      end
    end
  end

  describe '#create?' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.create?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, role: :owner) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.create?).to be true
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end
  end

  describe '#update?' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.update?).to be true
      end
    end

    context 'when user is owner of the company' do
      let!(:company) { create(:company) }
      let(:user) { company.owner }
      let(:record) { company }

      it 'permits access' do
        expect(subject.update?).to be true
      end
    end

    context 'when user is owner but not of this company' do
      let!(:company) { create(:company) }
      let!(:other_company) { create(:company) }
      let(:user) { other_company.owner }
      let(:record) { company }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end

    context 'when user is employee' do
      let(:company) { create(:company) }
      let(:user) { create(:user, :employee, company: company) }
      let(:record) { company }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end

    context 'when user is manager' do
      let(:company) { create(:company) }
      let(:user) { create(:user, :manager, company: company) }
      let(:record) { company }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end
  end

  describe '#destroy?' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }
      let(:record) { Company.new }

      it 'permits access' do
        expect(subject.destroy?).to be true
      end
    end

    context 'when user is owner of the company' do
      let!(:company) { create(:company) }
      let(:user) { company.owner }
      let(:record) { company }

      it 'permits access' do
        expect(subject.destroy?).to be true
      end
    end

    context 'when user is owner but not of this company' do
      let!(:company) { create(:company) }
      let!(:other_company) { create(:company) }
      let(:user) { other_company.owner }
      let(:record) { company }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end

    context 'when user is employee' do
      let(:company) { create(:company) }
      let(:user) { create(:user, :employee, company: company) }
      let(:record) { company }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end

    context 'when user is manager' do
      let(:company) { create(:company) }
      let(:user) { create(:user, :manager, company: company) }
      let(:record) { company }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }
      let(:record) { Company.new }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end
  end

  describe 'Scope' do
    let(:scope) { Company.all }

    describe '#resolve' do
      context 'when user is nil' do
        let(:user) { nil }

        it 'returns empty scope' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to eq(Company.none)
        end
      end

      context 'when user is admin' do
        let(:user) { create(:user, :admin) }
        let!(:company1) { create(:company) }
        let!(:company2) { create(:company) }

        it 'returns all companies' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to include(company1, company2)
          expect(policy_scope.count).to eq(2)
        end
      end

      context 'when user is owner' do
        let!(:company1) { create(:company) }
        let(:user) { company1.owner }
        let!(:company2) { create(:company) }

        it 'returns only companies owned by user' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to include(company1)
          expect(policy_scope).not_to include(company2)
          expect(policy_scope.count).to eq(1)
        end
      end

      context 'when owner has multiple companies' do
        let!(:company1) { create(:company) }
        let(:user) { company1.owner }
        let!(:company2) { create(:company, owner_user: user) }
        let!(:other_company) { create(:company) }

        it 'returns all companies owned by user' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to include(company1, company2)
          expect(policy_scope).not_to include(other_company)
          expect(policy_scope.count).to eq(2)
        end
      end

      context 'when user is employee' do
        let(:company) { create(:company) }
        let(:user) { create(:user, :employee, company: company) }
        let!(:other_company) { create(:company) }

        it 'returns only the company user belongs to' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to include(company)
          expect(policy_scope).not_to include(other_company)
          expect(policy_scope.count).to eq(1)
        end
      end

      context 'when user is employee without company' do
        let(:user) { build(:user, :employee, company: nil) }

        it 'returns empty scope' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to eq(Company.none)
        end
      end

      context 'when user is manager' do
        let(:company) { create(:company) }
        let(:user) { create(:user, :manager, company: company) }
        let!(:other_company) { create(:company) }

        it 'returns only the company user belongs to' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to include(company)
          expect(policy_scope).not_to include(other_company)
          expect(policy_scope.count).to eq(1)
        end
      end

      context 'when user is manager without company' do
        let(:user) { build(:user, :manager, company: nil) }

        it 'returns empty scope' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to eq(Company.none)
        end
      end

      context 'when user is customer' do
        let(:user) { build(:user, :customer) }

        it 'returns empty scope' do
          policy_scope = described_class::Scope.new(user, scope).resolve
          expect(policy_scope).to eq(Company.none)
        end
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from Crm::BasePolicy' do
      expect(described_class.superclass).to eq(Crm::BasePolicy)
    end
  end
end
