require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:admin) { User.create!(first_name: "ChrisP", last_name: "Bacon", email: "admin@email.com", password: "User@123", role: :admin, confirmed_at: Time.current) }

  let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }

  before do
    sign_in admin
  end
  describe "GET /admin/users" do
    it "renders index page" do
      get admin_users_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("trader@email.com")
    end
  end

  describe "GET /admin/users/:id" do
    it "shows user details" do
      get admin_user_path(trader)
      expect(response).to have_http_status(200)
      expect(response.body).to include("trader")
    end
  end

  describe "GET /admin/users/new" do
    it "renders new user form" do
      get new_admin_user_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Create")
    end
  end

  describe "POST /admin/users" do
    it "creates new user" do
      post admin_users_path, params: { user: { first_name: "Ben", last_name: "Beckman", email: "beckman@email.com", password: "User@123", password_confirmation: "User@123", status: :approved, balance: "500", confirmed_at: Time.current } }
      expect(response).to have_http_status(302)
      expect(User.all.count).to eq(3)
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "edit user details" do
      get edit_admin_user_path(trader)
      expect(response).to have_http_status(200)
      expect(trader.last_name).to include("Pray")
    end
  end

  describe "PUT /admin/users/:id" do
    it "update user details" do
      put admin_user_path(trader), params: { user: { first_name: "Ben", last_name: "Beckman", email: "beckman@email.com", password: "User@123", password_confirmation: "User@123", status: :approved, balance: "500", confirmed_at: Time.current } }

      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User was successfully updated.")
    end
  end

  describe "DELETE /admin/users/:id" do
    it "delete user" do
      delete admin_user_path(trader)
      expect(response).to have_http_status(302)
      expect(User.all.count).to eq(1)
    end
  end

   describe "PATCH /admin/users/:id/confirm" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current) }
    it "confirms the user account" do
      patch confirm_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User confirmed and email sent.")
    end
  end

  describe "PATCH /admin/users/:id/approve" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current) }
    it "approves the user account" do
      patch approve_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User approved and email sent.")
    end
  end

  describe "PATCH /admin/users/:id/reject" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current) }
    it "confirms the user account" do
      patch reject_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User rejected and email sent.")
    end
  end

  describe "PATCH /admin/users/:id/ban" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current, status: :approved) }
    it "ban the user account" do
      patch ban_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User banned and email sent.")
    end
  end

  describe "PATCH /admin/users/:id/unban" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, confirmed_at: Time.current, status: :banned) }
    it "re-activate the banned user account" do
      patch unban_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("User account re-activated and email sent.")
    end
  end

  describe "POST /admin/users/:id/resend_confirmation" do
    let!(:trader) { User.create!(first_name: "Lettuce", last_name: "Pray", email: "trader@email.com", password: "User@123", role: :trader, confirmation_sent_at: Time.current, status: :pending) }
    it "resend email confirmation to unconfirmed user" do
      post resend_confirmation_admin_user_path(trader)
      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("Confirmation email resent to trader@email.com")
    end
  end
end
