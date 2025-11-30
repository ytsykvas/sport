# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:customer_user) { create(:user, :customer) }

  before do
    routes.draw do
      namespace :admin do
        resources :users, only: [ :index, :show ]
      end
      root 'screener/home#index'
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

      it 'calls Admin::User::Operation::Index' do
        expect(Admin::User::Operation::Index).to receive(:call).with(
          params: anything,
          current_user: admin_user
        ).and_call_original
        get :index
      end

      it 'renders Admin::User::Component::Index' do
        result = instance_double(
          Base::Operation::Result,
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: OpenStruct.new(users: User.all),
          :[] => nil
        )
        allow(Admin::User::Operation::Index).to receive(:call).and_return(result)
        expect_any_instance_of(Admin::User::Component::Index).to receive(:render_in).and_return('users html')
        get :index
      end
    end

    context 'when user is not admin' do
      before do
        sign_in customer_user, scope: :user
      end

      it 'redirects with flash alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end

      it 'does not call Admin::User::Operation::Index' do
        expect(Admin::User::Operation::Index).not_to receive(:call)
        get :index
      end
    end

    context 'when user is not signed in' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects with flash alert' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end

      it 'does not call Admin::User::Operation::Index' do
        expect(Admin::User::Operation::Index).not_to receive(:call)
        get :index
      end
    end

    context 'with sorting parameters' do
      before do
        sign_in admin_user, scope: :user
      end

      it 'passes sorting parameters to operation' do
        expect(Admin::User::Operation::Index).to receive(:call).with(
          params: hash_including(sort_by: 'name', sort_direction: 'asc'),
          current_user: admin_user
        ).and_call_original
        get :index, params: { sort_by: 'name', sort_direction: 'asc' }
      end
    end
  end

  describe 'GET #show' do
    let(:target_user) { create(:user, :customer) }

    context 'when user is admin' do
      before do
        sign_in admin_user, scope: :user
      end

      it 'returns success status' do
        get :show, params: { id: target_user.id }
        expect(response).to have_http_status(:success)
      end

      it 'calls Admin::User::Operation::Show' do
        expect(Admin::User::Operation::Show).to receive(:call).with(
          params: hash_including(id: target_user.id.to_s),
          current_user: admin_user
        ).and_call_original
        get :show, params: { id: target_user.id }
      end

      it 'renders Admin::User::Component::Show' do
        result = instance_double(
          Base::Operation::Result,
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: OpenStruct.new(user: target_user),
          :[] => nil
        )
        allow(Admin::User::Operation::Show).to receive(:call).and_return(result)
        expect_any_instance_of(Admin::User::Component::Show).to receive(:render_in).and_return('user show html')
        get :show, params: { id: target_user.id }
      end
    end

    context 'when user is not admin' do
      before do
        sign_in customer_user, scope: :user
      end

      it 'redirects with flash alert' do
        get :show, params: { id: target_user.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end

      it 'does not call Admin::User::Operation::Show' do
        expect(Admin::User::Operation::Show).not_to receive(:call)
        get :show, params: { id: target_user.id }
      end
    end

    context 'when user is not signed in' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects with flash alert' do
        get :show, params: { id: target_user.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('authorization.admin_access_denied'))
      end

      it 'does not call Admin::User::Operation::Show' do
        expect(Admin::User::Operation::Show).not_to receive(:call)
        get :show, params: { id: target_user.id }
      end
    end

    context 'when user not found' do
      before do
        sign_in admin_user, scope: :user
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
