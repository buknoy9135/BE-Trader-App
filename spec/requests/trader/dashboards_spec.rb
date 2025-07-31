require 'rails_helper'

RSpec.describe "Trader::Dashboards", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current, status: :approved) }

  before do
    sign_in trader
  end
  describe "GET /trader/dashboard" do
    it "renders index page" do
      get trader_dashboard_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Ready to trade? Check your portfolio or start a new transaction below.")
    end
  end
end
