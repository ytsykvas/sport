# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BaseController, type: :controller do
  include Devise::Test::ControllerHelpers

  controller(Admin::BaseController) do
    def index
      render plain: 'OK'
    end
  end

  let(:admin_user) { create(:user, :admin) }
  let(:customer_user) { create(:user, :customer) }
  let!(:company) { create(:company) }
  let(:owner_user) { company.owner }

  before do
    routes.draw do
      namespace :admin do
        get 'index' => 'base#index'
      end
    end
  end

  describe 'authorization' do
    context 'when user is admin' do
      before do
        sign_in admin_user, scope: :user
      end

      it 'allows access' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not admin' do
      context 'when user is customer' do
        before do
          sign_in customer_user, scope: :user
          routes.draw do
            root 'screener/home#index'
            namespace :crm do
              root to: 'dashboard#index'
            end
            namespace :admin do
              get 'index' => 'base#index'
            end
          end
        end

        it 'redirects with flash alert' do
          get :index
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
        end
      end

      context 'when user is owner' do
        before do
          sign_in owner_user, scope: :user
          routes.draw do
            root 'screener/home#index'
            namespace :crm do
              root to: 'dashboard#index'
            end
            namespace :admin do
              get 'index' => 'base#index'
            end
          end
        end

        it 'redirects to crm with flash alert' do
          get :index
          expect(response).to redirect_to(crm_root_path)
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
              get 'index' => 'base#index'
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

  describe '#authorize_admin_access' do
    before do
      sign_in admin_user, scope: :user
    end

    it 'calls Admin::BasePolicy' do
      expect(Admin::BasePolicy).to receive(:new).with(admin_user, nil).and_call_original
      get :index
    end

    it 'checks index? permission' do
      policy = instance_double(Admin::BasePolicy, index?: true)
      allow(Admin::BasePolicy).to receive(:new).and_return(policy)
      expect(policy).to receive(:index?)
      get :index
    end
  end
end
