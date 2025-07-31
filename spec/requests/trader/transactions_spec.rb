require 'rails_helper'

RSpec.describe "Trader::Transactions", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current, status: :approved, balance: 50000) }

  let!(:transaction) { Transaction.create!(user: trader, asset_symbol: "AMZN", transaction_type: "buy", quantity: "10", price: "150", total_amount: "1500", status: "pending", executed_at: Time.current) }

  before do
    sign_in trader
  end
  describe "GET /trader/transactions" do
    it "render index page" do
      get trader_transactions_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Transactions")
    end
  end

  describe "GET /trader/transactions/:id" do
    it "shows transaction details" do
      get trader_transaction_path(transaction)
      expect(response).to have_http_status(200)
      expect(transaction.asset_symbol).to eq("AMZN")
    end
  end

  describe "GET /trader/transactions/new" do
    it "renders new transaction form" do
      get new_trader_transaction_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Search Stock Symbol")
    end
  end

  describe "POST /trader/transactions" do
    it "creates new transaction" do
      post trader_transactions_path, params: { transaction: { asset_symbol: "AMZN", quantity: 5, price: 150, transaction_type: "sell" } }
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("Stock sold successfully!")
    end
  end
end
