# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'anthropic'

RSpec.describe SpecGuardian do
  let(:test_file_path) { 'app/models/user.rb' }
  let(:test_source_code) { "class User < ApplicationRecord\n  validates :email, presence: true\nend" }
  let(:test_api_response) do
    {
      'id' => 'msg_0123MiRVCgSG2PaQZwCGbgmV',
      'type' => 'message',
      'role' => 'assistant',
      'content' => [{ 'type' => 'text', 'text' => '# Generated test content' }],
      'model' => 'claude-3-haiku-20240307',
      'stop_reason' => 'end_turn',
      'stop_sequence' => nil,
      'usage' => { 'input_tokens' => 17, 'output_tokens' => 32 }
    }
  end
  let(:test_client) { double('Client', messages: test_api_response) }

  before do
    # Setup test environment
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).and_return(test_source_code)
    allow(File).to receive(:write)
    allow(FileUtils).to receive(:mkdir_p)
    allow(Dir).to receive(:pwd).and_return('/rails_app')

    # Mock the Rails constant if it doesn't exist
    unless defined?(Rails)
      class Rails
        def self.version
          '7.0.0'
        end
      end
    end

    # Reset configuration before each test
    SpecGuardian.configuration = nil
  end

  describe '.version' do
    it 'has a version number' do
      expect(SpecGuardian::VERSION).not_to be nil
    end
  end

  describe '.configure' do
    it 'allows setting configuration options' do
      described_class.configure do |config|
        config.api_key = 'test_api_key'
        config.ai_model = 'test_model'
        config.max_tokens = 1000
        config.test_style = 'minimal'
      end

      expect(described_class.configuration.api_key).to eq('test_api_key')
      expect(described_class.configuration.ai_model).to eq('test_model')
      expect(described_class.configuration.max_tokens).to eq(1000)
      expect(described_class.configuration.test_style).to eq('minimal')
    end

    it 'uses default values when not specified' do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('env_api_key')
      described_class.configure {}

      expect(described_class.configuration.api_key).to eq('env_api_key')
      expect(described_class.configuration.ai_model).to eq('claude-3-7-sonnet-20250219')
      expect(described_class.configuration.max_tokens).to eq(20_000)
      expect(described_class.configuration.test_style).to eq('thorough')
    end
  end

  describe '.generate_test' do
    before do
      described_class.configure do |config|
        config.api_key = 'test_api_key'
      end

      allow(Anthropic::Client).to receive(:new).and_return(test_client)
      allow(SpecGuardian::TestFrameworkDetector).to receive(:detect).and_return(:rspec)
      allow(SpecGuardian::FilePathResolver).to receive(:resolve).and_return('spec/models/user_spec.rb')
    end

    it 'generates a test file for the given source file' do
      expect(FileUtils).to receive(:mkdir_p).with('spec/models')
      expect(File).to receive(:write).with('spec/models/user_spec.rb', '# Generated test content')

      result = described_class.generate_test(test_file_path)
      expect(result).to eq('spec/models/user_spec.rb')
    end

    it 'raises an error if the file does not exist' do
      allow(File).to receive(:exist?).with(test_file_path).and_return(false)

      expect do
        described_class.generate_test(test_file_path)
      end.to raise_error(SpecGuardian::Error, "File not found: #{test_file_path}")
    end
  end

  describe SpecGuardian::TestFrameworkDetector do
    describe '.detect' do
      it 'detects RSpec when spec directory and gemfile with rspec exist' do
        allow(File).to receive(:exist?).with('spec').and_return(true)
        allow(described_class).to receive(:gemfile_includes?).with('rspec').and_return(true)

        expect(described_class.detect).to eq(:rspec)
      end

      it 'detects Minitest when test directory and gemfile with minitest exist' do
        allow(File).to receive(:exist?).with('spec').and_return(false)
        allow(File).to receive(:exist?).with('test').and_return(true)
        allow(described_class).to receive(:gemfile_includes?).with('minitest').and_return(true)

        expect(described_class.detect).to eq(:minitest)
      end

      it 'falls back to Rails default in newer Rails versions' do
        allow(File).to receive(:exist?).with('spec').and_return(false)
        allow(File).to receive(:exist?).with('test').and_return(false)

        expect(described_class.detect).to eq(:minitest)
      end
    end
  end

  describe SpecGuardian::FilePathResolver do
    describe '.resolve' do
      it 'resolves model paths correctly for RSpec' do
        result = described_class.resolve('app/models/user.rb', :rspec)
        expect(result).to eq('spec/models/user_spec.rb')
      end

      it 'resolves controller paths correctly for RSpec' do
        result = described_class.resolve('app/controllers/users_controller.rb', :rspec)
        expect(result).to eq('spec/controllers/users_controller_spec.rb')
      end

      it 'resolves view paths correctly for RSpec' do
        result = described_class.resolve('app/views/users/index.html.erb', :rspec)
        expect(result).to eq('spec/views/users/index.html_spec.rb')
      end

      it 'handles paths with leading ./' do
        result = described_class.resolve('./app/models/user.rb', :rspec)
        expect(result).to eq('spec/models/user_spec.rb')
      end

      it 'resolves paths correctly for Minitest' do
        result = described_class.resolve('app/models/user.rb', :minitest)
        expect(result).to eq('test/models/user_spec.rb')
      end
    end
  end

  describe SpecGuardian::AiClient do
    let(:source_code) { 'class User < ApplicationRecord; end' }
    let(:file_path) { 'app/models/user.rb' }

    before do
      SpecGuardian.configure do |config|
        config.api_key = 'test_api_key'
        config.max_tokens = 20_000
        config.test_style = 'thorough'
      end

      allow(Anthropic::Client).to receive(:new).and_return(test_client)
    end

    describe '.generate_test' do
      fit 'makes the correct API call and returns the response' do
        expected_prompt = /generate a comprehensive Rails RSpec test for the following model code/

        allow(test_client).to receive(:messages).with(
          hash_including(
            parameters: {
              max_tokens: 20_000,
              model: 'claude-3-7-sonnet-20250219',
              messages: array_including(
                hash_including(
                  role: 'user',
                  content: a_string_matching(expected_prompt)
                )
              )
            }
          )
        ).and_return(test_api_response)

        result = described_class.generate_test(source_code, :rspec, file_path)
        expect(result).to eq('# Generated test content')
      end
    end

    describe '.detect_file_type' do
      it 'detects models correctly' do
        expect(described_class.detect_file_type('app/models/user.rb')).to eq(:model)
      end

      it 'detects controllers correctly' do
        expect(described_class.detect_file_type('app/controllers/users_controller.rb')).to eq(:controller)
      end

      it 'detects views correctly' do
        expect(described_class.detect_file_type('app/views/users/index.html.erb')).to eq(:view)
      end

      it 'detects helpers correctly' do
        expect(described_class.detect_file_type('app/helpers/users_helper.rb')).to eq(:helper)
      end

      it 'detects mailers correctly' do
        expect(described_class.detect_file_type('app/mailers/user_mailer.rb')).to eq(:mailer)
      end

      it 'detects jobs correctly' do
        expect(described_class.detect_file_type('app/jobs/process_user_job.rb')).to eq(:job)
      end

      it 'returns :other for unrecognized file types' do
        expect(described_class.detect_file_type('app/serializers/user_serializer.rb')).to eq(:other)
      end
    end

    describe '.create_prompt' do
      it 'creates the correct prompt for RSpec model tests' do
        prompt = described_class.create_prompt(source_code, :rspec, :model)

        expect(prompt).to include('Rails RSpec test')
        expect(prompt).to include('model code')
        expect(prompt).to include('Test style preference: thorough')
        expect(prompt).to include(source_code)
      end

      it 'creates the correct prompt for Minitest controller tests' do
        prompt = described_class.create_prompt(source_code, :minitest, :controller)

        expect(prompt).to include('Rails Minitest test')
        expect(prompt).to include('controller code')
        expect(prompt).to include('Test style preference: thorough')
        expect(prompt).to include(source_code)
      end
    end
  end
end
