# SpecGuardian

A Ruby gem that uses AI (Claude) to automatically generate test files for your Rails application code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spec_guardian'
```

And then execute:

```ruby
bundle install
```

Or install it yourself as:

```ruby
gem install spec_guardian
```

## Configuration

Create an initializer file at `config/initializers/spec_guardian.rb` by running the install command to create this file `rails g spec_guardian:install`

```ruby
SpecGuardian.configure do |config|
  config.api_key = ENV['ANTHROPIC_API_KEY'] # Your Anthropic API key
  config.ai_model = "claude-3-7-sonnet-20250219" # The Claude model to use
  config.max_tokens = 20_000 # The max tokens to use per request defaults to 20_000
  config.test_style = "thorough" # Options: minimal, thorough, edge_cases
end
```

NOTE: The `max_tokens` determines the length of the response. If you are seeing files cut off, then you need to increase this value.

Ensure you have your Anthropic API key set as an environment variable or directly in the configuration. You can signup here https://console.anthropic.com to generate an account and get an API key.

## Usage

### Command Line

You can use the executable to generate a test for any file in your Rails application:

```ruby
bundle exec spec_guardian app/models/user.rb
```

During testing, models files with around 200-300 lines of code cost around $0.02. This will vary of course depending on how complex your code is. If you have rubocop installed you may need to adjust specs. It also isn't 100% accurate with generating perfect code so expect to look over the files it generates and be ready to fix things.

### Rake Task

Alternatively, you can use the provided Rake task:

```ruby
bundle exec rake spec_guardian:generate[app/models/user.rb]
```

If you are using zsh you may need to quote your input:

```ruby
bundle exec rake spec_guardian:generate['app/models/user.rb']
```

## Features

1. Automatically detects whether your application uses RSpec or Minitest
2. Places generated test files in the appropriate location (spec/ or test/ directory)
3. Customizes test generation based on file type (model, controller, etc.)
4. Supports different test styles (minimal, thorough, or edge_cases)

## How It Works

1. The gem detects your project's test framework (RSpec, Minitest, or Rails default)
2. It analyzes the source file to determine its type (model, controller, etc.)
3. It sends the source code to Claude's API with a specialized prompt
4. It creates the test file in the correct location with the AI-generated test code

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/darrenterhune/spec_guardian.
