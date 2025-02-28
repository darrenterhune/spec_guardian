# frozen_string_literal: true

require_relative 'spec_guardian/version'
require_relative 'spec_guardian/configuration'
require_relative 'spec_guardian/test_framework_detector'
require_relative 'spec_guardian/file_path_resolver'
require_relative 'spec_guardian/ai_client'

module SpecGuardian
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def generate_test(file_path)
      # Validate the file exists
      raise Error, "File not found: #{file_path}" unless File.exist?(file_path)

      # Detect the test framework
      framework = TestFrameworkDetector.detect

      # Resolve the test file path
      test_file_path = FilePathResolver.resolve(file_path, framework)

      # Generate the test content
      source_code = File.read(file_path)
      test_content = AiClient.generate_test(source_code, framework, file_path)

      # Create the test file
      FileUtils.mkdir_p(File.dirname(test_file_path))
      File.write(test_file_path, test_content)

      puts "Test file generated: #{test_file_path}"
      test_file_path
    end
  end
end

require 'spec_guardian/railtie' if defined?(Rails)
