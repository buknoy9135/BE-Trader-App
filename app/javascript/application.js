// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

document.addEventListener("turbo:load", () => {
  // Re-initialize dropdowns
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((el) => {
    new bootstrap.Dropdown(el);
  });

  // Confirm fix (optional)
  Turbo.setConfirmMethod((message) => window.confirm(message));
});

