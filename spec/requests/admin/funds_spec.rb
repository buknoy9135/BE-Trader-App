require 'rails_helper'

RSpec.describe "Admin::Funds", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { User.create!(first_name: "ChrisP", last_name: "Bacon", email: "admin@email.com", password: "User@123", role: :admin, confirmed_at: Time.current) }

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }

  let!(:fund) { Fund.create!(amount: "3000", fund_type: "deposit", status: :pending, user: trader) }

  before do
    sign_in admin
  end
  describe "GET /admin/funds" do
    it "renders funds index page" do
      get admin_funds_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /admin/funds/:id" do
    it "shows fund details" do
      get admin_funds_path(fund)
      expect(response).to have_http_status(200)
      expect(response.body).to include("$3,000.00")
    end
  end

  describe "PATCH /admin/funds:id/approve" do
    it "approves the fund request" do
      patch approve_admin_fund_path(fund)
      expect(response).to have_http_status(302)
      fund.reload
      expect(fund.status).to eq("approved")
    end
  end

  describe "PATCH /admin/funds:id/reject" do
    it "rejects the fund request" do
      patch reject_admin_fund_path(fund)
      expect(response).to have_http_status(302)
      fund.reload
      expect(fund.status).to eq("rejected")
    end
  end
end
