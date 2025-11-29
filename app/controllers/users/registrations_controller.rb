# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    if params[:register_company] == "1"
      company_name = params[:company_name].presence || "#{resource.name}'s Company"

      ActiveRecord::Base.transaction do
        resource.role = :customer
        resource.save!

        company = create_company_for_owner(resource, company_name)

        resource.reload
        resource.role = :owner

        unless resource.valid?
          raise ActiveRecord::RecordInvalid.new(resource)
        end

        resource.save!

        unless company.reload.valid?
          resource.errors.add(:base, company.errors.full_messages.join(", "))
          raise ActiveRecord::RecordInvalid.new(company)
        end
      end

      if resource.persisted? && resource.owner?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        clean_up_passwords resource
        set_minimum_password_length
        # Clear flash alert since errors are shown in the form
        flash[:alert] = nil
        respond_with resource
      end
    else
      resource.role = :customer
      super
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Registration failed: #{e.record.class} - #{e.record.errors.full_messages.join(', ')}"
    clean_up_passwords resource
    set_minimum_password_length
    # Clear flash alert since errors are shown in the form
    flash[:alert] = nil
    respond_with resource
  end

  private

  def after_sign_up_path_for(resource)
    if resource.owner?
      crm_edit_company_path
    else
      super
    end
  end

  def create_company_for_owner(user, company_name)
    company = Company.new(
      name: company_name,
      owner: user
    )

    company.save(validate: false)

    unless company.persisted?
      user.errors.add(:base, "Failed to create company")
      raise ActiveRecord::RecordInvalid.new(company)
    end

    company
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
