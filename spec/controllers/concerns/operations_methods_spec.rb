# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperationsMethods, type: :controller do
  include Devise::Test::ControllerHelpers
  # Create a test controller that includes the concern
  controller(ApplicationController) do
    include OperationsMethods

    def index
      endpoint(TestOperation, TestComponent)
    end

    def create
      endpoint(TestOperation, TestComponent)
    end

    def update
      endpoint(TestOperation, TestComponent)
    end

    def destroy
      endpoint(TestOperation, TestComponent)
    end

    def edit
      endpoint(TestOperation, TestComponent)
    end

    def new
      endpoint(TestOperation, TestComponent)
    end

    def show_custom
      endpoint(TestOperation, TestComponent) do |result|
        @custom_callback_called = true
      end
      render plain: 'OK'
    end
  end

  # Test operation class
  let(:test_operation_class) do
    Class.new do
      def self.call(params:, current_user:)
        new(params:, current_user:).call
      end

      def initialize(params:, current_user:)
        @params = params
        @current_user = current_user
      end

      def call
        # Create a simple result object that responds to all needed methods
        result = Struct.new(:success?, :failure?, :message, :error_message, :redirect_path, :model, keyword_init: true).new(
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: User.new
        )

        # Add [] method to handle hash-like access
        result.define_singleton_method(:[]) { |key| nil }

        result
      end

      def to_s
        'TestOperation'
      end
    end
  end

  # Test component class
  let(:test_component_class) do
    Class.new do
      def initialize(**args)
        @args = args
      end

      def render_in(view_context)
        'test component html'
      end
    end
  end

  let(:user) { create(:user) }
  let(:successful_result) do
    double('Result',
      success?: true,
      failure?: false,
      message: 'Success message',
      error_message: nil,
      redirect_path: '/test/path',
      model: User.new,
      :[] => nil
    )
  end

  let(:failed_result) do
    double('Result',
      success?: false,
      failure?: true,
      message: nil,
      error_message: 'Error message',
      redirect_path: nil,
      model: User.new(email: 'test@example.com'),
      :[] => nil
    )
  end

  let(:result_with_openstruct) do
    double('Result',
      success?: true,
      failure?: false,
      message: nil,
      error_message: nil,
      redirect_path: '/test/path',
      model: OpenStruct.new(user: User.new),
      :[] => nil
    )
  end

  before do
    stub_const('TestOperation', test_operation_class)
    stub_const('TestComponent', test_component_class)
    routes.draw do
      get 'index' => 'anonymous#index'
      post 'create' => 'anonymous#create'
      patch 'update' => 'anonymous#update'
      delete 'destroy' => 'anonymous#destroy'
      get 'edit' => 'anonymous#edit'
      get 'new' => 'anonymous#new'
      get 'show_custom' => 'anonymous#show_custom'
      get 'anonymous' => 'anonymous#index', as: :anonymous
    end
    sign_in(user, scope: :user) if user
  end

  describe '#endpoint' do
    describe 'with HTML format' do
      describe 'create action' do
        context 'when operation succeeds' do
          before do
            allow(TestOperation).to receive(:call).and_return(successful_result)
          end

          it 'redirects to specified path' do
            post :create
            expect(response).to redirect_to('/test/path')
          end

          it 'sets flash notice' do
            post :create
            expect(flash[:notice]).to eq('Success message')
          end

          it 'calls the operation' do
            expect(TestOperation).to receive(:call).with(params: anything, current_user: user)
            post :create
          end
        end

        context 'when operation fails' do
          before do
            allow(TestOperation).to receive(:call).and_return(failed_result)
          end

          it 'renders the component' do
            expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
            post :create
          end

          it 'sets flash alert' do
            expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
            post :create
            expect(flash[:alert]).to eq('Error message')
          end
        end
      end

      describe 'update action' do
        context 'when operation succeeds' do
          before do
            allow(TestOperation).to receive(:call).and_return(successful_result)
          end

          it 'redirects to specified path' do
            patch :update, params: { id: 1 }
            expect(response).to redirect_to('/test/path')
          end

          it 'sets flash notice' do
            patch :update, params: { id: 1 }
            expect(flash[:notice]).to eq('Success message')
          end
        end
      end

      describe 'destroy action' do
        context 'when operation succeeds' do
          before do
            allow(TestOperation).to receive(:call).and_return(successful_result)
          end

          it 'redirects to specified path' do
            delete :destroy, params: { id: 1 }
            expect(response).to redirect_to('/test/path')
          end
        end

        context 'when operation fails' do
          before do
            allow(TestOperation).to receive(:call).and_return(failed_result)
          end

          it 'still redirects (special case for destroy)' do
            # Stub the dynamic path helper method
            controller.singleton_class.class_eval do
              define_method(:anonymous_path) { '/anonymous' }
            end
            delete :destroy, params: { id: 1 }
            expect(response).to redirect_to('/anonymous')
          end
        end
      end

      describe 'index action' do
        before do
          allow(TestOperation).to receive(:call).and_return(successful_result)
        end

        it 'renders the component' do
          expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
          get :index
        end

        it 'sets flash notice if present' do
          expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
          get :index
          expect(flash[:notice]).to eq('Success message')
        end
      end

      describe 'new action' do
        before do
          allow(TestOperation).to receive(:call).and_return(successful_result)
        end

        it 'renders the component' do
          expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
          get :new
        end
      end

      describe 'edit action' do
        before do
          allow(TestOperation).to receive(:call).and_return(successful_result)
          allow(controller).to receive(:render).and_call_original
        end

        it 'renders the component' do
          expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
          get :edit, params: { id: 1 }
        end
      end
    end

    describe 'with JS format' do
      describe 'create action' do
        context 'when operation succeeds' do
          before do
            allow(TestOperation).to receive(:call).and_return(successful_result)
          end

          it 'returns javascript redirect' do
            post :create, format: :js
            expect(response.content_type).to include('text/javascript')
            expect(response.body).to include("window.location.href='/test/path'")
          end

          it 'sets flash notice' do
            post :create, format: :js
            expect(flash[:notice]).to eq('Success message')
          end
        end

        context 'when operation fails' do
          before do
            allow(TestOperation).to receive(:call).and_return(failed_result)
          end

          it 'returns javascript for modal' do
            post :create, format: :js
            expect(response.content_type).to include('text/javascript')
            expect(response.body).to include('modal')
          end
        end
      end
    end

    describe 'with JSON format' do
      let(:mock_model) do
        double('MockModel', select2_search_result: { id: 1, text: 'Test' })
      end

      let(:collection) { [ mock_model ] }

      let(:collection_result) do
        double('Result',
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: collection,
          :[] => nil
        )
      end

      before do
        allow(TestOperation).to receive(:call).and_return(collection_result)
      end

      it 'returns JSON with collection' do
        get :index, format: :json
        expect(response.content_type).to include('application/json')
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('result')
        expect(json_response).to have_key('pagination')
      end

      it 'maps collection to select2 format' do
        expect(mock_model).to receive(:select2_search_result)
        get :index, format: :json
      end
    end

    describe 'with OpenStruct model' do
      before do
        allow(TestOperation).to receive(:call).and_return(result_with_openstruct)
      end

      it 'converts OpenStruct to hash for component params' do
        expect(TestComponent).to receive(:new).with(user: instance_of(User)).and_call_original
        expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
        get :index
      end
    end

    describe 'custom block callback' do
      before do
        allow(TestOperation).to receive(:call).and_return(successful_result)
      end

      it 'calls the provided block' do
        get :show_custom
        expect(controller.instance_variable_get(:@custom_callback_called)).to be true
      end
    end

    describe '#check_authorization_is_called' do
      let(:result_with_pundit) do
        double('Result',
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: '/test/path',
          model: User.new,
          :[] => true,
          :pundit => true,
          :pundit_scope => false
        )
      end

      before do
        allow(TestOperation).to receive(:call).and_return(result_with_pundit)
        allow(controller).to receive(:skip_authorization)
        allow(controller).to receive(:skip_policy_scope)
      end

      it 'skips authorization when pundit flag is true' do
        expect(controller).to receive(:skip_authorization)
        get :index
      end

      it 'skips policy scope when pundit_scope flag is true' do
        result = double('Result',
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: '/test/path',
          model: User.new,
          pundit: false,
          pundit_scope: true
        )
        allow(result).to receive(:[]) do |key|
          case key
          when :pundit_scope then true
          when :pundit then false
          else nil
          end
        end
        allow(TestOperation).to receive(:call).and_return(result)
        expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
        allow(controller).to receive(:render) do |arg|
          if arg.is_a?(TestComponent)
            controller.response_body = arg.render_in(controller.view_context)
          end
        end
        expect(controller).to receive(:skip_policy_scope)
        get :index
      end

      it 'skips authorization when operation fails' do
        allow(TestOperation).to receive(:call).and_return(failed_result)
        allow(controller).to receive(:render).and_call_original
        expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
        expect(controller).to receive(:skip_authorization)
        expect(controller).to receive(:skip_policy_scope)
        get :index
      end
    end

    describe 'redirect path fallback' do
      let(:result_without_redirect) do
        double('Result',
          success?: true,
          failure?: false,
          message: nil,
          error_message: nil,
          redirect_path: nil,
          model: User.new,
          :[] => nil
        )
      end

      before do
        allow(TestOperation).to receive(:call).and_return(result_without_redirect)
      end

      it 'uses controller_name_path as fallback' do
        # Stub the dynamic path helper method
        controller.singleton_class.class_eval do
          define_method(:anonymous_path) { '/anonymous' }
        end
        post :create
        expect(response).to redirect_to('/anonymous')
      end
    end

    describe 'operation key extraction' do
      context 'when operation is namespaced' do
        let(:namespaced_operation) do
          Class.new do
            def self.call(params:, current_user:)
              new(params:, current_user:).call
            end

            def initialize(params:, current_user:)
              @params = params
              @current_user = current_user
            end

            def call
              result = Struct.new(:success?, :failure?, :message, :error_message, :redirect_path, :model, keyword_init: true).new(
                success?: true,
                failure?: false,
                message: 'Success message',
                error_message: nil,
                redirect_path: '/test/path',
                model: User.new
              )

              result.define_singleton_method(:[]) { |key| nil }

              result
            end

            def self.to_s
              'Crm::Dashboard::Operation::Index'
            end
          end
        end

        controller(ApplicationController) do
          include OperationsMethods

          def index
            endpoint(Crm::Dashboard::Operation::Index, TestComponent)
          end
        end

        before do
          stub_const('Crm::Dashboard::Operation::Index', namespaced_operation)
          routes.draw do
            get 'index' => 'anonymous#index'
          end
        end

        it 'extracts first namespace as key' do
          expect(TestComponent).to receive(:new).with(crms: instance_of(User)).and_call_original
          expect_any_instance_of(TestComponent).to receive(:render_in).and_return('test html')
          allow(controller).to receive(:render) do |arg|
            if arg.is_a?(TestComponent)
              controller.response_body = arg.render_in(controller.view_context)
            end
          end
          get :index
        end
      end
    end
  end
end
