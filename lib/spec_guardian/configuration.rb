module SpecGuardian
  class Configuration
    attr_accessor :api_key, :ai_model, :test_style, :max_tokens

    def initialize
      @api_key = ENV['ANTHROPIC_API_KEY']
      @ai_model = 'claude-3-7-sonnet-20250219'
      @max_tokens = 20_000
      @test_style = 'thorough' # Options: minimal, thorough, edge_cases
    end
  end
end
