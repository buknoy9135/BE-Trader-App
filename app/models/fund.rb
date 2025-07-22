class Fund < ApplicationRecord
  belongs_to :user

  enum fund_type: { deposit: 0, withdraw: 1 }
  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
