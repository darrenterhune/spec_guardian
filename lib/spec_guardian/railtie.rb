require 'rails'

module SpecGuardian
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/generate_tests.rake'
    end
  end
end
