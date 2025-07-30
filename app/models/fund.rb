class Fund < ApplicationRecord
  belongs_to :user

  enum fund_type: { deposit: 0, withdraw: 1 }
  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :fund_type, presence: true

  # for approve when trader request for deposit or withdraw
  def apply_to_user_balance!
    if deposit?
      user.increment!(:balance, amount)
    else
      user.decrement!(:balance, amount)
    end
  end

  # to make sure negative balance won't go through when deposit or withdraw request is made
  def can_be_approved?
    deposit? || (withdraw? && user.balance >= amount)
  end
end
