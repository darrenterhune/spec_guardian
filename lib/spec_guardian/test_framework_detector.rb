module SpecGuardian
  class TestFrameworkDetector
    def self.detect
      return :rspec if File.exist?('spec') && gemfile_includes?('rspec')

      return :minitest if File.exist?('test') && gemfile_includes?('minitest')

      if Rails.version.to_i >= 5
        :minitest
      else
        :test_unit
      end
    end

    def self.gemfile_includes?(gem_name)
      return false unless File.exist?('Gemfile')

      File.read('Gemfile').include?(gem_name)
    end
  end
end
