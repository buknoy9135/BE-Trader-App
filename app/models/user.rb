class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Roles: admin = 0, trader = 1
  enum role: { admin: 0, trader: 1 }

  # Status: pending = 0, approved = 1, rejected = 2, banned = 3
  enum status: { pending: 0, approved: 1, rejected: 2, banned: 3 }

  validates :email, :encrypted_password, :first_name, :last_name, presence: true
end
