class Company < ApplicationRecord
  # Associations
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"
  has_many :users, dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :owner, presence: true
  validate :owner_must_have_owner_role, unless: -> { owner&.new_record? }

  private

  def owner_must_have_owner_role
    if owner.present? && owner.persisted? && !owner.owner?
      errors.add(:owner, "must have 'owner' role")
    end
  end
end
