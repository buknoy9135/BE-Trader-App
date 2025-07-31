require 'rails_helper'

RSpec.describe "Trader::Funds", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current, status: :approved) }

  let!(:fund) { Fund.create!(amount: "3000", fund_type: "deposit", status: :approved, user: trader) }

  before do
    sign_in trader
  end
  describe "GET /trader/funds" do
    it "render index page" do
      get trader_funds_path
      expect(response).to have_http_status(200)
      expect(fund.amount).to eq(3000)
    end
  end

  describe "GET /trader/funds/:id" do
    it "shows fund details" do
      get trader_fund_path(fund)
      expect(response).to have_http_status(200)
      expect(fund.fund_type).to include("deposit")
    end
  end

  describe "GET /trader/funds/new" do
    it "renders new user form" do
      get new_trader_fund_path
      expect(response).to have_http_status(200)
      expect(fund.status).to eq("approved")
    end
  end

  describe "POST /trader/funds/create" do
    it "creates new fund" do
      post trader_funds_path, params: { fund: { fund_type: "withdraw", amount: "1000", notes: "n/a" } }
      expect(response).to have_http_status(302)
      follow_redirect!
      expect(fund.status).to eq("approved")
    end
  end

  describe "GET /trader/funds/edit" do
    it "edits fund details" do
      get edit_trader_fund_path(fund)
      expect(response).to have_http_status(200)
      expect(fund.status).to eq("approved")
    end
  end

  describe "PATCH /trader/funds/:id" do
    it "update fund details" do
      patch trader_fund_path(fund), params: { fund: { fund_type: "deposit", amount: "1000", notes: "n/a" } }
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("Request updated successfully.")
    end
  end
end
