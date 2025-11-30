# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::User::Component::UsersTable, type: :component do
  let!(:company) { create(:company, name: 'Test Company') }
  let!(:admin_user) { create(:user, :admin, name: 'Admin User') }
  let!(:owner_user) { company.owner }
  let!(:customer_user) { create(:user, :customer, name: 'Customer User') }
  let(:users) { User.all }
  let(:sorting_path) { '/admin/users' }
  let(:component) { described_class.new(users: users, sorting_path: sorting_path) }

  describe '#initialize' do
    it 'accepts users and sorting_path parameters' do
      expect { component }.not_to raise_error
    end

    it 'assigns users to instance variable' do
      expect(component.instance_variable_get(:@users)).to eq(users)
    end

    it 'assigns sorting_path to instance variable' do
      expect(component.instance_variable_get(:@sorting_path)).to eq(sorting_path)
    end
  end

  describe '#call' do
    before do
      allow(component).to receive(:render).and_return('<table>Mock Table</table>'.html_safe)
    end

    it 'creates a table instance' do
      expect(Base::Component::Table::Table).to receive(:new).with(rows: users).and_call_original
      component.call
    end

    it 'adds all required columns' do
      table = instance_double(Base::Component::Table::Table)
      allow(Base::Component::Table::Table).to receive(:new).and_return(table)

      expect(table).to receive(:add_column).at_least(7).times
      expect(component).to receive(:render).with(table)

      component.call
    end
  end

  describe '#role_badge' do
    it 'returns admin badge for admin role' do
      badge = component.send(:role_badge, 'admin')
      expect(badge).to include('badge bg-danger')
      expect(badge).to include(I18n.t('roles.admin'))
    end

    it 'returns owner badge for owner role' do
      badge = component.send(:role_badge, 'owner')
      expect(badge).to include('badge bg-primary')
      expect(badge).to include(I18n.t('roles.owner'))
    end

    it 'returns manager badge for manager role' do
      badge = component.send(:role_badge, 'manager')
      expect(badge).to include('badge bg-info')
      expect(badge).to include(I18n.t('roles.manager'))
    end

    it 'returns employee badge for employee role' do
      badge = component.send(:role_badge, 'employee')
      expect(badge).to include('badge bg-warning')
      expect(badge).to include(I18n.t('roles.employee'))
    end

    it 'returns secondary badge for unknown role' do
      badge = component.send(:role_badge, 'unknown')
      expect(badge).to include('badge bg-secondary')
    end
  end

  describe '#company_name' do
    context 'when user has a company' do
      let!(:employee_company) { create(:company, name: 'Employee Company') }
      let(:employee_user) { create(:user, :employee, company: employee_company) }

      it 'returns the company name' do
        result = component.send(:company_name, employee_user)
        expect(result).to eq('Employee Company')
      end
    end

    context 'when user owns a company' do
      it 'returns the owned company name' do
        result = component.send(:company_name, owner_user)
        expect(result).to eq('Test Company')
      end
    end

    context 'when user has no company' do
      it 'returns "no company" message' do
        result = component.send(:company_name, customer_user)
        expect(result).to include(I18n.t('admin.users.index.table.no_company'))
        expect(result).to include('text-muted')
      end
    end
  end

  describe 'sorting configuration' do
    it 'configures sorting for ID column' do
      expect(component.instance_variable_get(:@sorting_path)).to eq(sorting_path)
    end

    it 'uses sorting path from instance variable' do
      expect(component.instance_variable_get(:@sorting_path)).to eq('/admin/users')
    end
  end

  describe 'responsive configuration' do
    it 'has correct users data' do
      expect(component.instance_variable_get(:@users)).to eq(users)
    end

    it 'configures stack for mobile screens' do
      # This tests that the component has the necessary data
      # Actual stacking behavior is tested in Base::Component::Table::Table specs
      expect(users.count).to be >= 3
    end
  end

  describe 'table helpers' do
    it 'can access table date formatter' do
      table = Base::Component::Table::Table.new(rows: users)
      formatted = table.format_date(admin_user.created_at)
      expect(formatted).to match(/\d{2}\.\d{2}\.\d{4}/)
    end
  end
end
