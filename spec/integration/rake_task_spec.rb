require 'spec_helper'
require 'rake'

RSpec.describe 'spec_guardian:generate rake task' do
  before do
    # Load the rake tasks
    load File.expand_path('../../lib/tasks/generate_tests.rake', __dir__)

    # Create a new Rake application and define the task
    Rake::Task.define_task(:environment)

    # Mock the Rails application environment
    unless defined?(Rails)
      class Rails
        def self.version
          '7.0.0'
        end
      end
    end

    # Setup test environment
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return('class User < ApplicationRecord; end')
    allow(File).to receive(:write)
    allow(FileUtils).to receive(:mkdir_p)

    # Configure the gem
    SpecGuardian.configure do |config|
      config.api_key = 'test_api_key'
    end

    # Mock the generate_test method to avoid actual API calls
    allow(SpecGuardian).to receive(:generate_test).and_return('spec/models/user_spec.rb')
  end

  it 'invokes SpecGuardian.generate_test with the correct file path' do
    # Set up task arguments
    args = Rake::TaskArguments.new([:file_path], ['app/models/user.rb'])

    # Execute the rake task
    expect(SpecGuardian).to receive(:generate_test).with('app/models/user.rb')
    Rake::Task['spec_guardian:generate'].execute(args)
  end

  it 'raises an error when no file_path is provided' do
    # Set up empty task arguments
    args = Rake::TaskArguments.new([:file_path], [nil])

    # Execute the rake task with no arguments should exit
    expect(Kernel).to receive(:exit).with(1)
    Rake::Task['spec_guardian:generate'].execute(args)
  end
end
