# frozen_string_literal: true

module SpecGuardian
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_config
        template('config/initializers/spec_guardian.rb')
      end
    end
  end
end
