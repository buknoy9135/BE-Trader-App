require 'rails_helper'

RSpec.describe "Admin::Portfolios", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { User.create!(first_name: "ChrisP", last_name: "Bacon", email: "admin@email.com", password: "User@123", role: :admin, confirmed_at: Time.current) }

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }

  before do
    sign_in admin
  end
  describe "GET /admin/portfolios/:id" do
    it "shows holdings" do
      trader.update!(balance: 5000)
      trader.transactions.create!(asset_symbol: "AAPL", quantity: 30, price: 100, transaction_type: "buy", status: "approved")
      trader.transactions.create!(asset_symbol: "AAPL", quantity: 5, price: 100, transaction_type: "sell", status: "approved")

      get admin_portfolio_path(trader)
      expect(response).to have_http_status(200)
      expect(response.body).to include("AAPL")
    end
  end
end
