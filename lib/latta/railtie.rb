require 'rails/railtie'

module Latta
  class Railtie < Rails::Railtie
    initializer "latta.configure_rails_initialization" do
      Rails.application.middleware.use Latta::Middleware
    end
  end
end