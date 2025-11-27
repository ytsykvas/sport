# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Base::Operation::Result do
  let(:result) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty attributes' do
      expect(result[:model]).to be_nil
    end

    it 'initializes forced_invalid as false' do
      expect(result.success?).to be true
    end
  end

  describe '#model' do
    let(:user) { build(:user) }

    it 'returns nil by default' do
      expect(result.model).to be_nil
    end

    it 'returns model when set' do
      result[:model] = user
      expect(result.model).to eq(user)
    end
  end

  describe '#redirect_path' do
    it 'returns nil by default' do
      expect(result.redirect_path).to be_nil
    end

    it 'returns redirect_path when set' do
      result[:redirect_path] = '/test/path'
      expect(result.redirect_path).to eq('/test/path')
    end
  end

  describe '#sub_results' do
    it 'returns empty array by default' do
      expect(result.sub_results).to eq([])
    end

    it 'returns sub_results when added' do
      sub_result = described_class.new
      result.sub_results << sub_result
      expect(result.sub_results).to include(sub_result)
    end
  end

  describe '#success?' do
    context 'when no errors and not forced invalid' do
      it 'returns true' do
        expect(result.success?).to be true
      end
    end

    context 'when has errors' do
      before do
        result.errors.add(:base, 'Test error')
      end

      it 'returns false' do
        expect(result.success?).to be false
      end
    end

    context 'when forced invalid' do
      before do
        result.invalid!
      end

      it 'returns false' do
        expect(result.success?).to be false
      end
    end

    context 'when model has errors' do
      let(:user) { build(:user, email: nil) }

      before do
        user.valid? # Trigger validations
        result[:model] = user
      end

      it 'returns false' do
        expect(result.success?).to be false
      end
    end

    context 'when has sub_results' do
      let(:successful_sub_result) { described_class.new }
      let(:failing_sub_result) do
        described_class.new.tap { |r| r.errors.add(:base, 'Sub error') }
      end

      context 'when all sub_results are successful' do
        before do
          result.sub_results << successful_sub_result
        end

        it 'returns true' do
          expect(result.success?).to be true
        end
      end

      context 'when any sub_result fails' do
        before do
          result.sub_results << successful_sub_result
          result.sub_results << failing_sub_result
        end

        it 'returns false' do
          expect(result.success?).to be false
        end
      end
    end
  end

  describe '#failure?' do
    context 'when successful' do
      it 'returns false' do
        expect(result.failure?).to be false
      end
    end

    context 'when has errors' do
      before do
        result.errors.add(:base, 'Test error')
      end

      it 'returns true' do
        expect(result.failure?).to be true
      end
    end
  end

  describe '#invalid!' do
    it 'forces result to be invalid' do
      result.invalid!
      expect(result.success?).to be false
      expect(result.failure?).to be true
    end
  end

  describe '#error_message' do
    context 'when no errors' do
      it 'returns empty string' do
        expect(result.error_message).to eq('')
      end
    end

    context 'when has single error' do
      before do
        result.errors.add(:base, 'Test error')
      end

      it 'returns error message' do
        expect(result.error_message).to eq('Test error')
      end
    end

    context 'when has multiple errors' do
      before do
        result.errors.add(:base, 'First error')
        result.errors.add(:base, 'Second error')
      end

      it 'returns joined error messages' do
        expect(result.error_message).to eq('First error Second error')
      end
    end
  end

  describe '#all_error_messages' do
    context 'when no errors' do
      it 'returns empty array' do
        expect(result.all_error_messages).to be_empty
      end
    end

    context 'when has errors' do
      before do
        result.errors.add(:base, 'First error')
        result.errors.add(:email, 'Invalid email')
      end

      it 'returns all error messages' do
        messages = result.all_error_messages
        expect(messages).to include('First error')
        expect(messages).to include('Invalid email')
      end
    end
  end

  describe '#message' do
    context 'when no notice set' do
      it 'returns nil' do
        expect(result.message).to be_nil
      end
    end

    context 'when notice is set' do
      before do
        result[:notice] = { text: 'Success!', level: :notice }
      end

      it 'returns notice text' do
        expect(result.message).to eq('Success!')
      end
    end
  end

  describe '#message_level' do
    context 'when no notice set' do
      it 'returns nil' do
        expect(result.message_level).to be_nil
      end
    end

    context 'when notice is set' do
      before do
        result[:notice] = { text: 'Success!', level: :success }
      end

      it 'returns notice level' do
        expect(result.message_level).to eq(:success)
      end
    end
  end

  describe 'delegation' do
    describe '#[]' do
      it 'delegates to @attrs' do
        result[:test_key] = 'test_value'
        expect(result[:test_key]).to eq('test_value')
      end
    end

    describe '#[]=' do
      it 'delegates to @attrs' do
        result[:test_key] = 'new_value'
        expect(result[:test_key]).to eq('new_value')
      end
    end

    describe '#fetch' do
      before do
        result[:existing_key] = 'value'
      end

      it 'delegates to @attrs' do
        expect(result.fetch(:existing_key)).to eq('value')
      end

      it 'returns default value for missing keys' do
        expect(result.fetch(:missing_key, 'default')).to eq('default')
      end
    end
  end
end
