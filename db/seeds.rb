# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(
  first_name: "Super",
  last_name: "Admin",
  email: "super-admin@email.com",
  password: ENV.fetch("SUPER_ADMIN_PASSWORD", nil),
  password_confirmation: ENV.fetch("SUPER_ADMIN_PASSWORD", nil),
  role: :admin,
  status: :approved,
  confirmed_at: Time.now
)

User.create!(
  first_name: "Jalil",
  last_name: "Abulais",
  email: "admin@email.com",
  password: ENV.fetch("ADMIN_PASSWORD", nil),
  password_confirmation: ENV.fetch("ADMIN_PASSWORD", nil),
  role: :admin,
  status: :approved,
  confirmed_at: Time.now
)
