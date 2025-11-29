# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:customer_user) { create(:user, :customer) }

  before do
    routes.draw do
      namespace :admin do
        root to: 'dashboard#index'
        resources :dashboard, only: [ :index ]
      end
    end
  end

  describe 'GET #index' do
    context 'when user is admin' do
      before do
        sign_in admin_user, scope: :user
      end

      it 'returns success status' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'calls Admin::Dashboard::Operation::Index' do
        expect(Admin::Dashboard::Operation::Index).to receive(:call).with(
          params: anything,
          current_user: admin_user
        ).and_call_original
        get :index
      end

      it 'renders Admin::Dashboard::Component::Index' do
        result = instance_double(
          Base::Operation::Result,
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: OpenStruct.new(users: User.all, companies: Company.all, admins: User.admin),
          :[] => nil
        )
        allow(Admin::Dashboard::Operation::Index).to receive(:call).and_return(result)
        expect_any_instance_of(Admin::Dashboard::Component::Index).to receive(:render_in).and_return('dashboard html')
        get :index
      end
    end

    context 'when user is not admin' do
      before do
        sign_in customer_user, scope: :user
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
            resources :dashboard, only: [ :index ]
          end
        end
      end

      it 'redirects with flash alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end
    end

    context 'when user is not signed in' do
      before do
        routes.draw do
          root 'screener/home#index'
          namespace :crm do
            root to: 'dashboard#index'
          end
          namespace :admin do
            root to: 'dashboard#index'
            resources :dashboard, only: [ :index ]
          end
        end
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects with flash alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end
    end
  end
end
