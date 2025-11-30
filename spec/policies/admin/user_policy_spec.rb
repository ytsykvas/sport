# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { build(:user) }

  describe 'inheritance' do
    it 'inherits from Admin::BasePolicy' do
      expect(described_class.superclass).to eq(Admin::BasePolicy)
    end

    it 'uses BasePolicy methods' do
      admin_user = build(:user, :admin)
      policy = described_class.new(admin_user, record)

      expect(policy.index?).to be true
      expect(policy.show?).to be true
      expect(policy.create?).to be true
      expect(policy.update?).to be true
      expect(policy.destroy?).to be true
    end
  end

  describe '#show?' do
    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'returns true' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, :owner) }

      it 'returns false' do
        expect(subject.show?).to be false
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }

      it 'returns false' do
        expect(subject.show?).to be false
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }

      it 'returns false' do
        expect(subject.show?).to be false
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.show?).to be false
      end
    end
  end

  describe 'Scope' do
    let(:admin_user) { create(:user, :admin) }
    let(:customer_user) { create(:user, :customer) }
    let!(:users) { create_list(:user, 3, :customer) }

    context 'when user is admin' do
      it 'returns all users' do
        scope = described_class::Scope.new(admin_user, User.all).resolve
        expect(scope.count).to be >= 4 # admin + 3 customers + possibly company owners
        expect(scope).to include(admin_user)
        expect(scope).to include(*users)
      end
    end

    context 'when user is not admin' do
      it 'returns empty collection' do
        scope = described_class::Scope.new(customer_user, User.all).resolve
        expect(scope).to be_empty
      end
    end

    context 'when user is nil' do
      it 'returns empty collection' do
        scope = described_class::Scope.new(nil, User.all).resolve
        expect(scope).to be_empty
      end
    end
  end
end
