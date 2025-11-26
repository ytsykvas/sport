class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums
  enum :role, { admin: 0, customer: 1, owner: 2, employee: 3, manager: 4 }

  # Associations
  belongs_to :company, optional: true
  has_one :owned_company, class_name: "Company", foreign_key: "owner_id", dependent: :destroy

  # Validations
  validates :name, presence: true
  validate :company_required_for_certain_roles
  validate :owner_can_have_only_one_company

  private

  def company_required_for_certain_roles
    if owner? && company_id.blank? && owned_company.blank?
      errors.add(:company, "must be present for #{role} role")
    elsif %w[employee manager].include?(role) && company_id.blank?
      errors.add(:company, "must be present for #{role} role")
    end
  end

  def owner_can_have_only_one_company
    if owner? && owned_company.present? && owned_company.persisted? && company_id.present? && company_id != owned_company.id
      errors.add(:base, "Owner can have only one company")
    end
  end
end
