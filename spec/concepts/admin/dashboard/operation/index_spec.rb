# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Dashboard::Operation::Index do
  let(:params) { {} }

  describe '.call' do
    context 'when user is admin' do
      let!(:admin) { create(:user, :admin) }
      let!(:other_users) { create_list(:user, 3, :customer) }
      let!(:companies) { create_list(:company, 2) }

      it 'returns success result' do
        result = described_class.call(params: params, current_user: admin)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
      end

      it 'returns OpenStruct with users, companies, and admins' do
        result = described_class.call(params: params, current_user: admin)
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.users).to be_present
        expect(result.model.companies).to be_present
        expect(result.model.admins).to be_present
      end

      it 'uses policy_scope for users' do
        result = described_class.call(params: params, current_user: admin)
        expect(result[:pundit_scope]).to be true
      end

      it 'returns all users through policy scope' do
        result = described_class.call(params: params, current_user: admin)
        # Companies create owners, so we check that our users are included
        expect(result.model.users.count).to be >= 4 # admin + 3 other users + company owners
        expect(result.model.users).to include(admin)
        expect(result.model.users).to include(*other_users)
      end

      it 'returns all companies through policy scope' do
        result = described_class.call(params: params, current_user: admin)
        # Companies may be created by other tests, so we check that our companies are included
        expect(result.model.companies.count).to be >= 2
        expect(result.model.companies).to include(*companies)
      end

      it 'returns only admin users in admins collection' do
        result = described_class.call(params: params, current_user: admin)
        expect(result.model.admins.count).to eq(1)
        expect(result.model.admins).to include(admin)
        expect(result.model.admins).not_to include(*other_users)
      end
    end

    context 'when user is not admin' do
      let(:customer) { create(:user, :customer) }

      it 'returns empty collections through policy scope' do
        result = described_class.call(params: params, current_user: customer)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
        # Policy scope returns empty collection for non-admins
        expect(result.model.users.count).to eq(0)
        expect(result.model.companies.count).to eq(0)
        expect(result.model.admins.count).to eq(0)
      end

      it 'uses policy_scope which restricts access' do
        result = described_class.call(params: params, current_user: customer)
        expect(result[:pundit_scope]).to be true
      end
    end

    context 'when there are no users or companies' do
      let(:admin) { create(:user, :admin) }

      it 'returns empty collections' do
        result = described_class.call(params: params, current_user: admin)
        expect(result.model.users.count).to eq(1) # only admin
        expect(result.model.companies.count).to eq(0)
        expect(result.model.admins.count).to eq(1) # only admin
      end
    end

    context 'when there are multiple admins' do
      let!(:admin1) { create(:user, :admin) }
      let!(:admin2) { create(:user, :admin) }
      let!(:customer) { create(:user, :customer) }

      it 'returns all admins in admins collection' do
        result = described_class.call(params: params, current_user: admin1)
        expect(result.model.admins.count).to eq(2)
        expect(result.model.admins).to include(admin1, admin2)
        expect(result.model.admins).not_to include(customer)
      end
    end
  end

  describe '#perform!' do
    let!(:admin) { create(:user, :admin) }
    let!(:users) { create_list(:user, 2, :customer) }
    let!(:companies) { create_list(:company, 2) }
    let(:operation) { described_class.new(params: params, current_user: admin) }

    before do
      operation.call
    end

    it 'sets model as OpenStruct with users, companies, and admins' do
      expect(operation.result.model).to be_a(OpenStruct)
      expect(operation.result.model.users).to be_present
      expect(operation.result.model.companies).to be_present
      expect(operation.result.model.admins).to be_present
    end

    it 'initializes model with nil values' do
      # This tests the pattern of initializing with nil then setting values
      operation_new = described_class.new(params: params, current_user: admin)
      operation_new.perform!(params: params, current_user: admin)
      expect(operation_new.result.model.users).to be_present
      expect(operation_new.result.model.companies).to be_present
      expect(operation_new.result.model.admins).to be_present
    end

    it 'calls policy_scope for users' do
      expect(operation.result[:pundit_scope]).to be true
    end

    it 'filters admins from users collection' do
      expect(operation.result.model.admins).to be_a(ActiveRecord::Relation)
      operation.result.model.admins.each do |user|
        expect(user).to be_admin
      end
    end
  end
end
