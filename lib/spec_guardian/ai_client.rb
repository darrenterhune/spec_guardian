require 'anthropic'

module SpecGuardian
  class AiClient
    def self.generate_test(source_code, framework, file_path)
      client = Anthropic::Client.new(
        access_token: SpecGuardian.configuration.api_key
      )

      # File type detection
      file_type = detect_file_type(file_path)

      # Create the prompt
      prompt = create_prompt(source_code, framework, file_type)
      model = SpecGuardian.configuration.ai_model
      max_tokens = SpecGuardian.configuration.max_tokens || 20_000

      # Make API call
      response = client.messages(
        parameters: {
          model: model,
          max_tokens: max_tokens,
          messages: [
            {
              role: 'user',
              content: prompt
            }
          ]
        }
      )

      # Extract and return the test code
      response['content'][0]['text']
    end

    def self.detect_file_type(file_path)
      if file_path.include?('/models/')
        :model
      elsif file_path.include?('/controllers/')
        :controller
      elsif file_path.include?('/views/')
        :view
      elsif file_path.include?('/helpers/')
        :helper
      elsif file_path.include?('/mailers/')
        :mailer
      elsif file_path.include?('/jobs/')
        :job
      else
        :other
      end
    end

    def self.create_prompt(source_code, framework, file_type)
      framework_name = framework == :rspec ? 'RSpec' : 'Minitest'
      style = SpecGuardian.configuration.test_style

      <<~PROMPT
        Generate a comprehensive Rails #{framework_name} test for the following #{file_type} code.
        The test should follow best practices for Rails testing with #{framework_name}.

        Test style preference: #{style}

        Here's the source code to test:

        ```ruby
        #{source_code}
        ```

        Please generate only the test code without any explanations. The output should be valid Ruby that can be saved directly to a test file. Remove comments. Do not include code formatting markdown like '```ruby'. Do not test rails internals like associations, scopes or table columns.
      PROMPT
    end
  end
end
