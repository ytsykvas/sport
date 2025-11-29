# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Crm::Company::Operation::Edit do
  let(:params) { {} }

  describe '.call' do
    context 'when user is owner' do
      let!(:company) { create(:company) }
      let(:owner) { company.owner }

      it 'returns success result' do
        result = described_class.call(params: params, current_user: owner)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
      end

      it 'returns company in model' do
        result = described_class.call(params: params, current_user: owner)
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.company).to eq(company)
      end

      it 'authorizes access' do
        result = described_class.call(params: params, current_user: owner)
        expect(result[:pundit]).to be true
      end

      it 'uses policy scope' do
        result = described_class.call(params: params, current_user: owner)
        expect(result[:pundit_scope]).to be true
      end
    end

    context 'when user is admin' do
      let(:admin) { create(:user, :admin) }
      let!(:company) { create(:company) }

      it 'returns success result' do
        result = described_class.call(params: params, current_user: admin)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
      end

      it 'returns company in model' do
        result = described_class.call(params: params, current_user: admin)
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.company).to eq(company)
      end

      it 'authorizes access' do
        result = described_class.call(params: params, current_user: admin)
        expect(result[:pundit]).to be true
      end
    end

    context 'when user is employee' do
      let(:company) { create(:company) }
      let(:employee) { create(:user, :employee, company: company) }

      it 'raises Pundit::NotAuthorizedError because employee cannot update' do
        expect do
          described_class.call(params: params, current_user: employee)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when user is manager' do
      let(:company) { create(:company) }
      let(:manager) { create(:user, :manager, company: company) }

      it 'raises Pundit::NotAuthorizedError because manager cannot update' do
        expect do
          described_class.call(params: params, current_user: manager)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when user has no company' do
      let(:customer) { create(:user, :customer) }

      it 'returns success result' do
        result = described_class.call(params: params, current_user: customer)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
      end

      it 'returns nil company in model' do
        result = described_class.call(params: params, current_user: customer)
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.company).to be_nil
      end

      it 'does not authorize when company is nil' do
        result = described_class.call(params: params, current_user: customer)
        expect(result[:pundit]).to be_nil
      end
    end

    context 'when owner has multiple companies' do
      let!(:first_company) { create(:company) }
      let(:owner) { first_company.owner }
      let!(:second_company) { create(:company, owner: owner) }

      it 'returns first company from scope' do
        result = described_class.call(params: params, current_user: owner)
        expect(result.model.company).to eq(first_company)
      end
    end

    context 'when user is customer with company but not owner' do
      let!(:other_company) { create(:company) }
      let(:customer) { create(:user, :customer, company: other_company) }

      it 'returns success result with nil company (customer not in scope)' do
        result = described_class.call(params: params, current_user: customer)
        expect(result).to be_a(Base::Operation::Result)
        expect(result.success?).to be true
        expect(result.model.company).to be_nil
      end

      it 'does not authorize when company is not in scope' do
        result = described_class.call(params: params, current_user: customer)
        expect(result[:pundit]).to be_nil
      end
    end
  end

  describe '#perform!' do
    let!(:company) { create(:company) }
    let(:owner) { company.owner }
    let(:operation) { described_class.new(params: params, current_user: owner) }

    before do
      operation.call
    end

    it 'sets model as OpenStruct with company' do
      expect(operation.result.model).to be_a(OpenStruct)
      expect(operation.result.model.company).to eq(company)
    end

    it 'calls policy_scope' do
      expect(operation.result[:pundit_scope]).to be true
    end

    it 'calls authorize!' do
      expect(operation.result[:pundit]).to be true
    end
  end
end
