# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BasePolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { double('Record') }

  describe '#index?' do
    context 'when user is nil' do
      let(:user) { nil }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, role: :owner) }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end
  end

  describe '#show?' do
    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.show?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.show?).to be false
      end
    end
  end

  describe '#create?' do
    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.create?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end
  end

  describe '#update?' do
    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.update?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.update?).to be false
      end
    end
  end

  describe '#destroy?' do
    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.destroy?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end
  end

  describe 'Scope' do
    let(:admin_user) { create(:user, :admin) }
    let(:customer_user) { create(:user, :customer) }
    let!(:users) { create_list(:user, 3, :customer) }

    context 'when user is admin' do
      it 'returns all records' do
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

  describe 'inheritance' do
    it 'inherits from ApplicationPolicy' do
      expect(described_class.superclass).to eq(ApplicationPolicy)
    end

    it 'has access to parent methods' do
      user = build(:user, :admin)
      policy = described_class.new(user, record)

      expect(policy).to respond_to(:index?)
      expect(policy).to respond_to(:show?)
      expect(policy).to respond_to(:create?)
      expect(policy).to respond_to(:update?)
      expect(policy).to respond_to(:destroy?)
    end
  end
end
