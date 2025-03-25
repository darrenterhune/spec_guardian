# config/initializers/spec_guardian.rb
SpecGuardian.configure do |config|
  config.api_key = ENV['ANTHROPIC_API_KEY'] # Your Anthropic API key
  config.ai_model = 'claude-3-7-sonnet-20250219' # The Claude model to use
  config.max_tokens = '20_000' # The max tokens to use per request defaults to 20_000
  config.test_style = 'thorough' # Options: minimal, thorough, edge_cases
end
