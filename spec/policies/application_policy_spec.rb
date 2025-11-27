require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { double('Record') }

  describe 'with admin user' do
    let(:user) { build(:user, :admin) }

    it 'denies index' do
      expect(subject.index?).to be false
    end

    it 'denies show' do
      expect(subject.show?).to be false
    end

    it 'denies create' do
      expect(subject.create?).to be false
    end

    it 'denies new' do
      expect(subject.new?).to be false
    end

    it 'denies update' do
      expect(subject.update?).to be false
    end

    it 'denies edit' do
      expect(subject.edit?).to be false
    end

    it 'denies destroy' do
      expect(subject.destroy?).to be false
    end
  end

  describe 'with customer user' do
    let(:user) { build(:user, :customer) }

    it 'denies index' do
      expect(subject.index?).to be false
    end

    it 'denies show' do
      expect(subject.show?).to be false
    end

    it 'denies create' do
      expect(subject.create?).to be false
    end

    it 'denies new' do
      expect(subject.new?).to be false
    end

    it 'denies update' do
      expect(subject.update?).to be false
    end

    it 'denies edit' do
      expect(subject.edit?).to be false
    end

    it 'denies destroy' do
      expect(subject.destroy?).to be false
    end
  end

  describe 'with nil user' do
    let(:user) { nil }

    it 'denies index' do
      expect(subject.index?).to be false
    end

    it 'denies show' do
      expect(subject.show?).to be false
    end

    it 'denies create' do
      expect(subject.create?).to be false
    end

    it 'denies new' do
      expect(subject.new?).to be false
    end

    it 'denies update' do
      expect(subject.update?).to be false
    end

    it 'denies edit' do
      expect(subject.edit?).to be false
    end

    it 'denies destroy' do
      expect(subject.destroy?).to be false
    end
  end

  describe '#new?' do
    let(:user) { build(:user) }

    it 'delegates to create?' do
      allow(subject).to receive(:create?).and_return(true)
      expect(subject.new?).to eq(true)
    end

    it 'returns false when create? is false' do
      allow(subject).to receive(:create?).and_return(false)
      expect(subject.new?).to eq(false)
    end
  end

  describe '#edit?' do
    let(:user) { build(:user) }

    it 'delegates to update?' do
      allow(subject).to receive(:update?).and_return(true)
      expect(subject.edit?).to eq(true)
    end

    it 'returns false when update? is false' do
      allow(subject).to receive(:update?).and_return(false)
      expect(subject.edit?).to eq(false)
    end
  end

  describe ApplicationPolicy::Scope do
    subject { described_class.new(user, scope) }

    let(:user) { build(:user) }
    let(:scope) { double('Scope') }

    describe '#resolve' do
      it 'raises NoMethodError with descriptive message' do
        expect { subject.resolve }.to raise_error(
          NoMethodError,
          /You must define #resolve in/
        )
      end
    end

    describe 'attributes' do
      it 'has user reader' do
        expect(subject.send(:user)).to eq(user)
      end

      it 'has scope reader' do
        expect(subject.send(:scope)).to eq(scope)
      end
    end
  end

  describe 'initialization' do
    let(:user) { build(:user) }

    it 'sets user attribute' do
      policy = described_class.new(user, record)
      expect(policy.user).to eq(user)
    end

    it 'sets record attribute' do
      policy = described_class.new(user, record)
      expect(policy.record).to eq(record)
    end
  end
end
