require 'rails_helper'

RSpec.describe Crm::BasePolicy, type: :policy do
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

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }

      it 'denies access' do
        expect(subject.index?).to be false
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

  describe 'different role combinations' do
    context 'with created user instances' do
      it 'permits access for created admin' do
        user = create(:user, :admin)
        policy = described_class.new(user, record)
        expect(policy.index?).to be true
      end

      it 'permits access for created employee' do
        user = create(:user, :employee)
        policy = described_class.new(user, record)
        expect(policy.index?).to be true
      end

      it 'permits access for created manager' do
        user = create(:user, :manager)
        policy = described_class.new(user, record)
        expect(policy.index?).to be true
      end

      it 'denies access for created customer' do
        user = create(:user, :customer)
        policy = described_class.new(user, record)
        expect(policy.index?).to be false
      end
    end
  end
end
