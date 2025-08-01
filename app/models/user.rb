class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable,  and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  # Roles: admin = 0, trader = 1
  enum role: { admin: 0, trader: 1 }

  # Status: pending = 0, approved = 1, rejected = 2, banned = 3
  enum status: { pending: 0, approved: 1, rejected: 2, banned: 3 }

  scope :traders, -> { where(role: :trader).order(updated_at: :desc) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  scope :pending_traders, -> { traders.pending.unconfirmed.order(confirmation_sent_at: :desc) }
  scope :confirmed_traders, -> { traders.pending.confirmed.order(confirmed_at: :desc) }
  scope :approved_traders, -> { traders.approved.confirmed.order("current_sign_in_at DESC NULLS LAST, updated_at DESC") }
  scope :rejected_traders, -> { traders.rejected.order(confirmation_sent_at: :desc) }
  scope :banned_traders, -> { traders.banned.order(updated_at: :desc) }

  # user validation on model side
  validates :email, :first_name, :last_name, presence: true
  validates :password, presence: true, if: :password_required?

  # dependencies
  has_many :funds
  has_many :transactions

  # # ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "first_name", "last_name", "status" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "funds", "transactions" ]
  end

  def password_required?
    new_record? || password.present?
  end

  # this is for hard-coded SUPER Admin
  SUPER_ADMIN_EMAIL = "super-admin@email.com"

  def super_admin?
    email == SUPER_ADMIN_EMAIL
  end

  def total_stock_quantity(symbol)
    bought = transactions.where(asset_symbol: symbol, transaction_type: :buy).sum(:quantity)
    sold = transactions.where(asset_symbol: symbol, transaction_type: :sell).sum(:quantity)
    bought - sold
  end
end
