# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::User::Operation::Show do
  let(:admin_user) { create(:user, :admin) }
  let(:target_user) { create(:user, :customer) }

  describe '#perform!' do
    context 'when user is admin' do
      it 'returns success result' do
        result = described_class.call(
          params: { id: target_user.id },
          current_user: admin_user
        )

        expect(result).to be_success
      end

      it 'returns user in model' do
        result = described_class.call(
          params: { id: target_user.id },
          current_user: admin_user
        )

        expect(result.model.user).to eq(target_user)
      end

      it 'returns OpenStruct as model' do
        result = described_class.call(
          params: { id: target_user.id },
          current_user: admin_user
        )

        expect(result.model).to be_a(OpenStruct)
      end

      it 'authorizes show action' do
        expect_any_instance_of(described_class).to receive(:authorize!).with(target_user, :show?).and_call_original

        described_class.call(
          params: { id: target_user.id },
          current_user: admin_user
        )
      end

      it 'finds correct user by id' do
        result = described_class.call(
          params: { id: target_user.id },
          current_user: admin_user
        )

        expect(result.model.user.id).to eq(target_user.id)
        expect(result.model.user.name).to eq(target_user.name)
        expect(result.model.user.email).to eq(target_user.email)
      end
    end

    context 'when user is not admin' do
      let(:regular_user) { create(:user, :customer) }

      it 'raises authorization error' do
        expect {
          described_class.call(
            params: { id: target_user.id },
            current_user: regular_user
          )
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when user not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.call(
            params: { id: 999999 },
            current_user: admin_user
          )
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when params are invalid' do
      it 'raises error when id is nil' do
        expect {
          described_class.call(
            params: { id: nil },
            current_user: admin_user
          )
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
