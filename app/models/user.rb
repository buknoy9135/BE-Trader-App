class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  # Roles: admin = 0, trader = 1
  enum role: { admin: 0, trader: 1 }

  # Status: pending = 0, approved = 1, rejected = 2, banned = 3
  enum status: { pending: 0, approved: 1, rejected: 2, banned: 3 }

  # user validation on model side
  validates :email, :first_name, :last_name, presence: true
  validates :password, presence: true, if: :password_required?


  def password_required?
    new_record? || password.present?
  end

  # this is for hard-coded SUPER Admin
  SUPER_ADMIN_EMAIL = "super-admin@email.com"

  def super_admin?
    email == SUPER_ADMIN_EMAIL
  end
end
