# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Sidebar::Component::AdminSidebar, type: :component do
  let(:admin_user) { create(:user, :admin) }
  let(:component_with_user) { described_class.new(current_user: admin_user) }
  let(:component_without_user) { described_class.new(current_user: nil) }

  before do
    allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/admin'))
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
        expect(component_with_user.user_name).to eq(admin_user.name)
      end
    end

    context 'when user has no name' do
      let(:user_without_name) { build(:user, :admin, name: nil, email: 'admin@example.com') }
      let(:component) { described_class.new(current_user: user_without_name) }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(double(path: '/admin'))
      end

      it 'returns the email username' do
        expect(component.user_name).to eq('admin')
      end
    end

    context 'when user is not present' do
      it 'returns nil' do
        expect(component_without_user.user_name).to be_nil
      end
    end
  end

  describe '#active_nav_class' do
    context 'when path is /admin/dashboard' do
      let(:request_double) { double(path: '/admin/dashboard') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns "active" for /admin/dashboard path' do
        expect(component_with_user.active_nav_class('/admin/dashboard')).to eq('active')
      end
    end

    context 'when path is /admin (root)' do
      let(:request_double) { double(path: '/admin') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns "active" for /admin path when checking /admin/dashboard' do
        expect(component_with_user.active_nav_class('/admin/dashboard')).to eq('active')
      end
    end

    context 'when path is /admin/users' do
      let(:request_double) { double(path: '/admin/users') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns "active" for /admin/users path' do
        expect(component_with_user.active_nav_class('/admin/users')).to eq('active')
      end

      it 'returns empty string for /admin/dashboard path' do
        expect(component_with_user.active_nav_class('/admin/dashboard')).to eq('')
      end
    end

    context 'when path is /admin/companies' do
      let(:request_double) { double(path: '/admin/companies') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns "active" for /admin/companies path' do
        expect(component_with_user.active_nav_class('/admin/companies')).to eq('active')
      end
    end

    context 'when path does not match' do
      let(:request_double) { double(path: '/crm/dashboard') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns empty string' do
        expect(component_with_user.active_nav_class('/admin/dashboard')).to eq('')
      end
    end

    context 'when path is /admin/settings' do
      let(:request_double) { double(path: '/admin/settings') }

      before do
        allow_any_instance_of(described_class).to receive(:request).and_return(request_double)
      end

      it 'returns "active" for /admin/settings path' do
        expect(component_with_user.active_nav_class('/admin/settings')).to eq('active')
      end
    end
  end
end
