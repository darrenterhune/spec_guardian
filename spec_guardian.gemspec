# frozen_string_literal: true

require_relative 'lib/spec_guardian/version'

Gem::Specification.new do |spec|
  spec.name          = 'spec_guardian'
  spec.version       = SpecGuardian::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Darren Terhune']
  spec.email         = ['darrenterhune@gmail.com']

  spec.summary       = 'Generate test files for Rails apps using AI'
  spec.description   = 'A gem that uses AI to automatically generate test files for your Rails application code'
  spec.homepage      = 'https://github.com/darrenterhune/spec_guardian'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.6')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['spec_guardian']
  spec.require_paths = ['lib']

  spec.add_dependency 'anthropic', '~> 0.3.2'
  spec.add_dependency 'rails', '~> 6.0'
  spec.add_dependency 'rake', '~> 12.0'
  spec.add_dependency 'thor', '~> 1.2'
  spec.add_development_dependency 'pry', '~> 0.15.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.73', '>= 1.73.1'
  spec.add_development_dependency 'rubocop-packaging', '~> 0.5.2'
  spec.add_development_dependency 'rubocop-performance', '~> 1.24'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop-shopify', '~> 2.15', '>= 2.15.1'
  spec.add_development_dependency 'rubocop-thread_safety', '~> 0.7.0'
end
