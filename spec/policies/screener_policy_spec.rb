require 'rails_helper'

RSpec.describe ScreenerPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { double('Record') }

  describe '#access?' do
    context 'when user is nil' do
      let(:user) { nil }

      it 'permits access' do
        expect(subject.access?).to be true
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, :admin) }

      it 'permits access' do
        expect(subject.access?).to be true
      end
    end

    context 'when user is customer' do
      let(:user) { build(:user, :customer) }

      it 'permits access' do
        expect(subject.access?).to be true
      end
    end

    context 'when user is owner' do
      let(:user) { build(:user, role: :owner) }

      it 'denies access' do
        expect(subject.access?).to be false
      end
    end

    context 'when user is employee' do
      let(:user) { build(:user, :employee) }

      it 'denies access' do
        expect(subject.access?).to be false
      end
    end

    context 'when user is manager' do
      let(:user) { build(:user, :manager) }

      it 'denies access' do
        expect(subject.access?).to be false
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from ApplicationPolicy' do
      expect(described_class.superclass).to eq(ApplicationPolicy)
    end

    it 'has access to parent methods' do
      user = build(:user, :customer)
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
        expect(policy.access?).to be true
      end

      it 'permits access for created customer' do
        user = create(:user, :customer)
        policy = described_class.new(user, record)
        expect(policy.access?).to be true
      end

      it 'denies access for created employee' do
        user = create(:user, :employee)
        policy = described_class.new(user, record)
        expect(policy.access?).to be false
      end

      it 'denies access for created manager' do
        user = create(:user, :manager)
        policy = described_class.new(user, record)
        expect(policy.access?).to be false
      end
    end
  end

  describe 'public access for anonymous users' do
    let(:user) { nil }

    it 'allows anonymous access to screener' do
      expect(subject.access?).to be true
    end

    it 'is accessible without authentication' do
      policy = described_class.new(nil, record)
      expect(policy.access?).to be true
    end
  end

  describe 'access control logic' do
    it 'grants access to public and customer roles only' do
      customer = build(:user, :customer)
      admin = build(:user, :admin)
      owner = build(:user, role: :owner)
      employee = build(:user, :employee)
      manager = build(:user, :manager)

      expect(described_class.new(nil, record).access?).to be true
      expect(described_class.new(customer, record).access?).to be true
      expect(described_class.new(admin, record).access?).to be true
      expect(described_class.new(owner, record).access?).to be false
      expect(described_class.new(employee, record).access?).to be false
      expect(described_class.new(manager, record).access?).to be false
    end
  end
end
