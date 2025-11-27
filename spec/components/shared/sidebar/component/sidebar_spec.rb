# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Sidebar::Component::Sidebar, type: :component do
  let!(:company) { create(:company, name: 'Sidebar Company') }
  let(:user) { company.owner }
  let(:component_with_user) { described_class.new(current_user: user) }
  let(:component_without_user) { described_class.new(current_user: nil) }

  before do
    allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/crm'))
  end

  describe '#initialize' do
    it 'accepts current_user parameter' do
      expect { component_with_user }.not_to raise_error
    end

    it 'works without current_user' do
      expect { component_without_user }.not_to raise_error
    end
  end

  describe '#signed_in?' do
    context 'when user is present' do
      it 'returns true' do
        expect(component_with_user.signed_in?).to be true
      end
    end

    context 'when user is not present' do
      it 'returns false' do
        expect(component_without_user.signed_in?).to be false
      end
    end
  end

  describe '#user_name' do
    context 'when user has a name' do
      it 'returns the user name' do
        expect(component_with_user.user_name).to eq(user.name)
      end
    end

    context 'when user has no name' do
      let(:user_without_name) { build(:user, name: nil, email: 'sidebar@example.com') }
      let(:component) { described_class.new(current_user: user_without_name) }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/'))
      end

      it 'returns the email username' do
        expect(component.user_name).to eq('sidebar')
      end
    end

    context 'when user is not present' do
      it 'returns nil' do
        expect(component_without_user.user_name).to be_nil
      end
    end
  end

  describe '#active_nav_class' do
    let(:request_double) { double(path: '/crm/dashboard') }

    before do
      allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
    end

    context 'when path matches' do
      it 'returns "active"' do
        expect(component_with_user.active_nav_class('/crm')).to eq('active')
      end
    end

    context 'when path does not match' do
      it 'returns empty string' do
        expect(component_with_user.active_nav_class('/screener')).to eq('')
      end
    end
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:admin_user) { create(:user, :admin) }
      let(:component) { described_class.new(current_user: admin_user) }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/'))
      end

      it 'returns true' do
        expect(component.admin?).to be true
      end
    end

    context 'when user is not admin' do
      it 'returns false' do
        expect(component_with_user.admin?).to be false
      end
    end

    context 'when user is not present' do
      it 'returns nil' do
        expect(component_without_user.admin?).to be_nil
      end
    end
  end

  describe '#owner?' do
    context 'when user is owner' do
      it 'returns true' do
        expect(component_with_user.owner?).to be true
      end
    end

    context 'when user is not owner' do
      let(:employee_company) { create(:company) }
      let(:employee_user) { create(:user, :employee, company: employee_company) }
      let(:component) { described_class.new(current_user: employee_user) }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/'))
      end

      it 'returns false' do
        expect(component.owner?).to be false
      end
    end

    context 'when user is not present' do
      it 'returns nil' do
        expect(component_without_user.owner?).to be_nil
      end
    end
  end

  describe '#company_name' do
    context 'when user has a company' do
      it 'returns the company name' do
        expect(component_with_user.company_name).to eq('Sidebar Company')
      end
    end

    context 'when user owns a company' do
      it 'returns the owned company name' do
        expect(component_with_user.company_name).to eq(company.name)
      end
    end

    context 'when user has no company' do
      let(:customer_user) { create(:user, :customer) }
      let(:component) { described_class.new(current_user: customer_user) }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/'))
      end

      it 'returns nil' do
        expect(component.company_name).to be_nil
      end
    end
  end
end
