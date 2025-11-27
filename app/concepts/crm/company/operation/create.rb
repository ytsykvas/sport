# frozen_string_literal: true

class Crm::Company::Operation::Create < Base::Operation::Base
  def call
    super
    # Move all errors to :base so error_message can return them
    # Use full_messages from user.errors for proper translations
    if result.model.is_a?(User)
      user = result.model
      # Add user's full error messages to result.errors[:base]
      user.errors.full_messages.each do |full_message|
        result.errors.add(:base, full_message) unless result.errors[:base].include?(full_message)
      end
      # Remove attribute-specific errors that were already added as full_messages
      result.errors.messages.each do |attribute, messages|
        next if attribute == :base
        result.errors.delete(attribute)
      end
      result[:model] = ::OpenStruct.new(user: user)
    end
    result
  end

  def perform!(params:, current_user:)
    skip_authorize
    user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    user = params[:resource] || User.new(user_params)
    company_name = params[:company_name].presence || "#{user.name}'s Company"

    # Set model as user first so base class can copy errors properly
    self.model = user

    ActiveRecord::Base.transaction do
      user.role = :customer
      user.save!

      company = Company.new(
        name: company_name,
        owner: user
      )
      company.save(validate: false)

      unless company.persisted?
        user.errors.add(:base, "Failed to create company")
        raise ActiveRecord::RecordInvalid.new(user)
      end

      user.reload
      user.role = :owner
      user.save!

      unless company.reload.valid?
        user.errors.add(:base, company.errors.full_messages.join(", "))
        raise ActiveRecord::RecordInvalid.new(user)
      end

      self.redirect_path = "/crm"
      notice("Successfully registered!", level: :notice)
      # Convert to OpenStruct for component after successful save
      self.model = ::OpenStruct.new(user: user)
    end
  end
end
