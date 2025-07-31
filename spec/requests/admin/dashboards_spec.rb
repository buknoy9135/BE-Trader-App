require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { User.create!(first_name: "ChrisP", last_name: "Bacon", email: "admin@email.com", password: "User@123", role: :admin, confirmed_at: Time.current) }

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }

  before do
    sign_in admin
  end
  it "returns a list of created trader)" do
    get admin_dashboard_path
    expect(response.body).to include("Lettuce")
  end

  it "returns the index page" do
    get admin_dashboard_path
    expect(response).to have_http_status(200)
  end

  it "shows trader email" do
    get admin_user_path(trader)
    expect(response.body).to include("trader@email.com")
  end
end
