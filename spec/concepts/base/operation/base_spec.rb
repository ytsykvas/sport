# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Base::Operation::Base do
  # Create a test operation class
  let(:test_operation_class) do
    Class.new(described_class) do
      def perform!(params:, current_user:)
        self.model = User.new(email: params[:email])
      end
    end
  end

  let(:failing_operation_class) do
    Class.new(described_class) do
      def perform!(params:, current_user:)
        user = User.new
        self.model = user
        user.save! # Will fail validation
      end
    end
  end

  let(:user) { create(:user) }
  let(:params) { { email: 'test@example.com' } }

  describe '.call' do
    it 'creates new instance and calls #call' do
      result = test_operation_class.call(params:, current_user: user)
      expect(result).to be_a(Base::Operation::Result)
    end

    it 'returns result object' do
      result = test_operation_class.call(params:, current_user: user)
      expect(result.model).to be_a(User)
      expect(result.model.email).to eq('test@example.com')
    end
  end

  describe '#initialize' do
    it 'stores attributes' do
      operation = test_operation_class.new(params:, current_user: user)
      expect(operation.result).to be_a(Base::Operation::Result)
    end

    it 'initializes result object' do
      operation = test_operation_class.new(params:, current_user: user)
      expect(operation.result).to be_present
    end
  end

  describe '#call' do
    let(:operation) { test_operation_class.new(params:, current_user: user) }

    it 'calls perform! method' do
      expect(operation).to receive(:perform!).and_call_original
      operation.call
    end

    it 'returns result' do
      result = operation.call
      expect(result).to be_a(Base::Operation::Result)
    end

    context 'when ActiveRecord::RecordInvalid is raised' do
      let(:operation) { failing_operation_class.new(params: {}, current_user: user) }

      it 'catches the exception and adds errors' do
        result = operation.call
        expect(result.failure?).to be true
        expect(result.errors).not_to be_empty
      end

      it 'does not raise exception' do
        expect { operation.call }.not_to raise_error
      end
    end
  end

  describe '#model=' do
    let(:operation) { test_operation_class.new(params:, current_user: user) }
    let(:test_user) { build(:user) }

    it 'sets the model on result' do
      operation.call
      expect(operation.result.model).to be_a(User)
    end
  end

  describe '#model' do
    let(:operation) { test_operation_class.new(params:, current_user: user) }

    it 'returns the model from result' do
      operation.call
      expect(operation.result.model).to be_a(User)
    end
  end

  describe '#redirect_path=' do
    let(:operation_with_redirect) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          self.redirect_path = '/test/path'
        end
      end
    end

    it 'sets redirect path on result' do
      result = operation_with_redirect.call(params:, current_user: user)
      expect(result.redirect_path).to eq('/test/path')
    end
  end

  describe '#notice' do
    let(:operation_with_notice) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          notice('Operation successful', level: :notice)
        end
      end
    end

    it 'sets notice message on result' do
      result = operation_with_notice.call(params:, current_user: user)
      expect(result.message).to eq('Operation successful')
      expect(result.message_level).to eq(:notice)
    end
  end

  describe '#add_error' do
    let(:operation_with_error) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          add_error(:test, 'Test error message')
        end
      end
    end

    it 'adds error to result' do
      result = operation_with_error.call(params:, current_user: user)
      expect(result.errors[:base]).to be_present
    end
  end

  describe '#invalid!' do
    let(:operation_with_invalid) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          invalid!
        end
      end
    end

    it 'marks result as invalid' do
      result = operation_with_invalid.call(params:, current_user: user)
      expect(result.failure?).to be true
    end
  end

  describe '#skip_authorize' do
    let(:operation_with_skip) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          skip_authorize
        end
      end
    end

    it 'sets pundit flag on result' do
      result = operation_with_skip.call(params:, current_user: user)
      expect(result[:pundit]).to be true
    end
  end

  describe '#skip_policy_scope' do
    let(:operation_with_skip_scope) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          skip_policy_scope
        end
      end
    end

    it 'sets pundit_scope flag on result' do
      result = operation_with_skip_scope.call(params:, current_user: user)
      expect(result[:pundit_scope]).to be true
    end
  end

  describe '#run_operation' do
    let(:sub_operation_class) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          self.model = params[:value]
        end
      end
    end

    let(:parent_operation_class) do
      Class.new(described_class) do
        def perform!(params:, current_user:)
          result = run_operation(params[:sub_operation], { params: { value: 'test' }, current_user: })
          self.model = result.model
        end
      end
    end

    it 'runs sub operation and returns result' do
      result = parent_operation_class.call(
        params: { sub_operation: sub_operation_class },
        current_user: user
      )
      expect(result.model).to eq('test')
      expect(result.sub_results).not_to be_empty
    end

    context 'when sub operation fails' do
      let(:failing_sub_operation) do
        Class.new(described_class) do
          def perform!(params:, current_user:)
            add_error(:base, 'Sub operation failed')
            invalid!
          end
        end
      end

      let(:parent_with_failing_sub) do
        Class.new(described_class) do
          def perform!(params:, current_user:)
            run_operation(params[:sub_operation], { params: {}, current_user: })
          end
        end
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect do
          parent_with_failing_sub.call(
            params: { sub_operation: failing_sub_operation },
            current_user: user
          )
        end.not_to raise_error # It's caught and added to errors
      end
    end
  end

  describe 'private methods' do
    describe '#copy_errors_from_result_to_model' do
      let(:operation_with_model_errors) do
        Class.new(described_class) do
          def perform!(params:, current_user:)
            user = User.new
            self.model = user
            add_error(:base, 'Test error')
          end
        end
      end

      it 'copies errors from result to model' do
        result = operation_with_model_errors.call(params: {}, current_user: user)
        expect(result.model.errors[:base]).to include('Test error')
      end
    end

    describe '#add_errors' do
      let(:user_with_errors) { build(:user, email: nil) }

      let(:operation_copying_errors) do
        Class.new(described_class) do
          def perform!(params:, current_user:)
            user = User.new
            user.valid?
            self.model = user
            add_errors(user.errors)
          end
        end
      end

      before do
        user_with_errors.valid? # Trigger validations
      end

      it 'adds errors from another object' do
        result = operation_copying_errors.call(params: {}, current_user: user)
        expect(result.errors).not_to be_empty
      end
    end
  end
end
