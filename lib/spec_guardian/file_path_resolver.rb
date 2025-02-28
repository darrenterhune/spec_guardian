require 'fileutils'

module SpecGuardian
  class FilePathResolver
    def self.resolve(file_path, framework)
      # Remove leading ./ if present
      file_path = file_path.sub(%r{^\./}, '')

      # Extract the relative path from app/
      relative_path = if file_path.start_with?('app/')
                        file_path.sub(%r{^app/}, '')
                      else
                        file_path
                      end

      # Determine test directory based on framework
      test_dir = framework == :rspec ? 'spec' : 'test'

      # Handle different file types
      if relative_path.start_with?('models/')
        "#{test_dir}/#{relative_path.sub(/\.rb$/, '_spec.rb')}"
      elsif relative_path.start_with?('controllers/')
        "#{test_dir}/#{relative_path.sub(/\.rb$/, '_spec.rb')}"
      elsif relative_path.start_with?('views/')
        view_path = relative_path.sub(%r{^views/}, '')
        "#{test_dir}/views/#{view_path.sub(/\.\w+\.erb$/, '.html_spec.rb')}"
      else
        # For other files, maintain the same structure
        "#{test_dir}/#{relative_path.sub(/\.rb$/, '_spec.rb')}"
      end
    end
  end
end
