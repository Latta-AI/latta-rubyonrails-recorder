module Latta
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'latta_initializer.rb', 'config/initializers/latta.rb'
      end
    end
  end
end