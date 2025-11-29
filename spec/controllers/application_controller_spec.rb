# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Create a test controller that inherits from ApplicationController
  controller(ApplicationController) do
    def index
      raise Pundit::NotAuthorizedError.new(policy: policy_instance, query: :index?)
    end

    def test_action
      raise Pundit::NotAuthorizedError.new(policy: policy_instance, query: :show?)
    end

    private

    def policy_instance
      @policy_instance ||= policy_class.new(current_user, nil)
    end

    def policy_class
      @policy_class ||= Admin::BasePolicy
    end
  end

  let(:admin_user) { create(:user, :admin) }
  let!(:company) { create(:company) }
  let(:owner_user) { company.owner }
  let(:employee_user) { create(:user, :employee, company: company) }
  let(:manager_user) { create(:user, :manager, company: company) }
  let(:customer_user) { create(:user, :customer) }

  describe '#user_not_authorized' do
    context 'when Admin::BasePolicy raises error' do
      before do
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
          end
          get 'index' => 'anonymous#index'
          get 'test_action' => 'anonymous#test_action'
        end
        allow(controller).to receive(:crm_root_path).and_return('/crm') if controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:crm_root_path) { '/crm' } unless controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:policy_class) { Admin::BasePolicy }
      end

      context 'when user is owner' do
        before do
          sign_in owner_user, scope: :user
        end

        it 'sets flash alert with admin access denied message' do
          get :index
          expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
        end

        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end
      end

      context 'when user is employee' do
        before do
          sign_in employee_user, scope: :user
        end

        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end
      end

      context 'when user is manager' do
        before do
          sign_in manager_user, scope: :user
        end

        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end
      end

      context 'when user is customer' do
        before do
          sign_in customer_user, scope: :user
        end

        it 'sets flash alert with admin access denied message' do
          get :index
          expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
        end

        it 'redirects to root_path' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when user is not signed in' do
        it 'sets flash alert with admin access denied message' do
          get :index
          expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
        end

        it 'redirects to root_path' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'when Crm::BasePolicy raises error' do
      before do
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
          end
          get 'index' => 'anonymous#index'
          get 'test_action' => 'anonymous#test_action'
        end
        allow(controller).to receive(:crm_root_path).and_return('/crm') if controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:crm_root_path) { '/crm' } unless controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:policy_class) { Crm::BasePolicy }
      end

      context 'when user is owner' do
        before do
          sign_in owner_user, scope: :user
        end

        it 'sets flash alert with crm access denied message' do
          get :index
          expect(flash[:alert]).to eq(I18n.t('authorization.crm_access_denied'))
        end

        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end
      end

      context 'when user is customer' do
        before do
          sign_in customer_user, scope: :user
        end

        it 'does not set flash alert' do
          get :index
          expect(flash[:alert]).to be_nil
        end

        it 'redirects to root_path' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when user is not signed in' do
        it 'redirects to root_path' do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'when Screener::BasePolicy raises error' do
      before do
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
          end
          get 'index' => 'anonymous#index'
          get 'test_action' => 'anonymous#test_action'
        end
        allow(controller).to receive(:crm_root_path).and_return('/crm') if controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:crm_root_path) { '/crm' } unless controller.respond_to?(:crm_root_path)
        controller.define_singleton_method(:policy_class) { Screener::BasePolicy }
      end

      context 'when user is signed in' do
        before do
          sign_in customer_user, scope: :user
        end

        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end

        it 'does not set flash alert' do
          get :index
          expect(flash[:alert]).to be_nil
        end
      end

      context 'when user is not signed in' do
        it 'redirects to crm_root_path' do
          get :index
          expect(response).to redirect_to(crm_root_path)
        end
      end
    end

    context 'when other policy raises error' do
      before do
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
          end
          get 'index' => 'anonymous#index'
          get 'test_action' => 'anonymous#test_action'
        end
        other_policy_class = Class.new(ApplicationPolicy) do
          def index?
            false
          end
        end
        controller.define_singleton_method(:policy_class) { other_policy_class }
        sign_in customer_user, scope: :user
      end

      it 'sets flash alert with action access denied message' do
        get :index
        expect(flash[:alert]).to eq(I18n.t('authorization.action_access_denied'))
      end

      it 'redirects back with fallback to root_path' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#configure_permitted_parameters' do
    # This method is tested indirectly through Devise controllers
    # It's a protected method that runs as a before_action for devise_controller?
    # Direct testing would require complex Devise setup, so we skip explicit tests
    # The functionality is verified through integration tests with Devise
  end

  describe 'helper methods' do
    it 'exposes current_user as helper method' do
      sign_in admin_user, scope: :user
      expect(controller.helpers).to respond_to(:current_user)
    end
  end
end
