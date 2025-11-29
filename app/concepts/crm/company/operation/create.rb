# frozen_string_literal: true

class Crm::Company::Operation::Create < Base::Operation::Base
  def call
    super

    if result.model.is_a?(User)
      user = result.model
      user.errors.full_messages.each do |full_message|
        result.errors.add(:base, full_message) unless result.errors[:base].include?(full_message)
      end
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
      self.model = ::OpenStruct.new(user: user)
    end
  end
end
