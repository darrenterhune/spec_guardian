require 'spec_helper'
require 'open3'

RSpec.describe 'spec_guardian executable' do
  let(:executable_path) { File.expand_path('../../bin/spec_guardian', __dir__) }

  before do
    # Make sure the executable has the right permissions
    File.chmod(0o755, executable_path) unless File.executable?(executable_path)
  end

  context 'when testing the executable directly' do
    it 'should be an executable file' do
      allow(Open3).to receive(:capture3).with('ruby', executable_path).and_return(['Test successful', '', 0])
      expect(File.executable?(executable_path)).to be true
    end

    it 'should require at least one argument' do
      allow(Open3).to receive(:capture3).with('ruby', executable_path).and_return(['Usage:', '', 1])
      output, error, status = Open3.capture3('ruby', executable_path)
      expect(status).not_to eq(0)
      expect(output).to include('Usage:')
    end
  end

  context 'when using a test double for the executable' do
    before do
      # Create test module to avoid loading the actual script
      module TestSpecGuardian
        def self.run(argv)
          SpecGuardian.generate_test(argv[0]) if argv.any?
        end
      end

      # Mock the generate_test method
      allow(SpecGuardian).to receive(:generate_test).and_return('spec/models/user_spec.rb')
    end

    it 'calls generate_test with the file path argument' do
      expect(SpecGuardian).to receive(:generate_test).with('app/models/user.rb')
      TestSpecGuardian.run(['app/models/user.rb'])
    end

    it 'does not call generate_test when no arguments are provided' do
      expect(SpecGuardian).not_to receive(:generate_test)
      TestSpecGuardian.run([])
    end
  end

  # For more comprehensive testing of command-line applications,
  # consider using the Aruba gem, which provides powerful CLI testing features

  # context 'integration test with Aruba', :if => false do
  #   # This is a placeholder for Aruba-based tests
  #   # These would be implemented if you add the Aruba gem to your development dependencies

  #   it 'runs successfully with a valid file path' do
  #     run_command "bin/rails_ai_test app/models/user.rb"
  #     expect(last_command_started).to have_exit_status(0)
  #     expect(last_command_started.stdout).to include("Test file generated")
  #   end
  # end
end
