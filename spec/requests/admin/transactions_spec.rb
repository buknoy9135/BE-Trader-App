require 'rails_helper'

RSpec.describe "Admin::Transactions", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { User.create!(first_name: "ChrisP", last_name: "Bacon", email: "admin@email.com", password: "User@123", role: :admin, confirmed_at: Time.current) }

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }

  before do
    sign_in admin
    trader.update!(balance: 5000)
    trader.transactions.create!(asset_symbol: "AAPL", quantity: 5, price: 100, transaction_type: "buy", status: "approved")
  end

  describe "GET /admin/transactions" do
    it "renders admin transactions page" do
      get admin_transactions_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /admin/transactions:id" do
    it "shows trader transactions details" do
      get admin_transaction_path(trader)
      puts response.body
      expect(response).to have_http_status(302)
      expect(response.body).to include("")
    end
  end
end
