# frozen_string_literal: true

# template.rb
def source_paths
  [__dir__]
end

# Remove unnecessary files and gems
remove_file 'app/views'
remove_file 'app/assets'
remove_file 'app/javascript'
remove_file 'app/helpers'
remove_file 'app/channels'
remove_file 'app/jobs'
remove_file 'app/mailers'
remove_file 'app/models'
remove_file 'public'
remove_file 'script'
remove_file 'vendor'

# Remove unnecessary routes
route 'root to: ->(_) { [204, {}, ["MCP SERVER <%= Rails.application.to_s %> (<%= Rails.application.version.to_s %>)"]] }'

gsub_file 'config/application.rb', %r{require "active_model/railtie"\n}, ''
gsub_file 'config/application.rb', %r{require "active_job/railtie"\n}, ''

# Remove unnecessary gems
gsub_file 'Gemfile', /^gem ["']sprockets-rails.*\n/, ''
gsub_file 'Gemfile', /^gem ["']stimulus-rails.*\n/, ''
gsub_file 'Gemfile', /^gem ["']turbo-rails.*\n/, ''
gsub_file 'Gemfile', /^gem ["']web-console.*\n/, ''
gsub_file 'Gemfile', /^# Use Redis.*\n/, ''
gsub_file 'Gemfile', /^# gem ["']redis.*\n/, ''
gsub_file 'Gemfile', /^# Use Kredis.*\n/, ''
gsub_file 'Gemfile', /^# gem ["']kredis.*\n/, ''
gsub_file 'Gemfile', /^# Use Active Model.*\n/, ''
gsub_file 'Gemfile', /^# gem ["']bcrypt.*\n/, ''
gsub_file 'Gemfile', /^gem ["']rails.*\n/, ''

# Configure API only
environment 'config.api_only = true'

gem 'railties', '~> 8.0.0'
gem 'actionpack', '~> 8.0.0'
gem 'rails_app_version'

# Create API directory structure
empty_directory 'app/controllers/api'

# Create base API controller
file 'app/controllers/api/base_controller.rb', <<~RUBY
  module Api
    class BaseController < ActionController::API
      abstract!

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end
    end
  end
RUBY

# Create mcp tools config
create_file 'config/mcp_tools.yml', <<~YAML
  shared:
    tools:
      - name: tool_name
        description: Description of what the tool does in <%= Rails.application.name %>
        input_schema:
          type: object
          properties:
            param1:
              type: string
              description: Description of parameter 1
            param2:
              type: integer
              description: Description of parameter 2
            param3:
              type: array
              items:
                type: string
              description: Description of parameter 3
          required:
            - param1
      - name: get_current_time
        description: Get current time in a specific timezone (this is an example tool)
        input_schema:
          type: object
          properties:
            timezone:
              type: string
              description: IANA timezone name (e.g., 'America/New_York', 'Europe/London')
          required:
            - timezone
YAML

# Create mcp prompts config
create_file 'config/mcp_prompts.yml', <<~YAML
  shared:
    prompts:
      - name: git-commit
        description: Generate a Git commit message
        arguments:
          - name: changes
            description: Git diff or description of changes
            required: true
      - name: explain-code
        description: Explain how code works
        arguments:
          - name: code
            description: Code to explain
            required: true
          - name: language
            description: Programming language
            required: false
YAML

# Create tools controller
create_file 'app/controllers/api/tools_controller.rb', <<~'RUBY'
  module Api
    class ToolsController < BaseController
       class UnknownToolError < StandardError; end
       class ToolExecutionError < StandardError; end

      def list
        tools = Rails.application.config_for(:mcp_tools)["tools"]
        render json: { tools: tools }
      end

      def call_tool
      result = execute_tool(tool_params[:name], tool_params[:arguments])
        render_success(result: result)
      rescue UnknownToolError => e
        render_error(e.message, :bad_request)
      rescue ToolExecutionError => e
        render_error(e.message, :unprocessable_entity)
      rescue StandardError => e
        render_error("Internal tool execution error: #{e.message}", :internal_server_error)
      end

      private

      def execute_tool(tool_name, arguments)
        tool_method = "execute_#{tool_name}"

        if respond_to?(tool_method, true)
          send(tool_method, arguments)
        else
          raise UnknownToolError, "Unknown tool: #{tool_name}"
        end
      end

      def render_success(data)
        render json: data, status: :ok
      end

      def execute_tool_name(args)
        # Implementation for tool_name
        raise ToolExecutionError, "Tool not implemented yet"
      end

      def tool_params
        params.permit(:name, arguments: {})
      end
    end
  end
RUBY

# Create prompts controller
create_file 'app/controllers/api/prompts_controller.rb', <<~'RUBY'
  module Api
    class PromptsController < BaseController
      class UnknownPromptError < StandardError; end
      class InvalidArgumentError < StandardError; end

      def list
        prompts = Rails.application.config_for(:mcp_prompts)["prompts"]
        render json: { prompts: prompts }
      end

      def get
        prompt = find_prompt(prompt_params[:name])
        validate_arguments!(prompt, prompt_params[:arguments])

        messages = generate_messages(prompt, prompt_params[:arguments])
        render json: { messages: messages }
      rescue UnknownPromptError, InvalidArgumentError => e
        render_error(e.message, :bad_request)
      rescue StandardError => e
        render_error("Internal prompt execution error: #{e.message}", :internal_server_error)
      end

      private

      def find_prompt(name)
        prompts = Rails.application.config_for(:mcp_prompts)["prompts"]
        prompt = prompts.find { |p| p["name"] == name }
        raise UnknownPromptError, "Unknown prompt: #{name}" unless prompt

        prompt
      end

      def validate_arguments!(prompt, provided_arguments)
        required_args = prompt["arguments"]&.select { |arg| arg["required"] }&.map { |arg| arg["name"] } || []
        
        missing_args = required_args - (provided_arguments&.keys || [])
        raise InvalidArgumentError, "Missing required arguments: #{missing_args.join(', ')}" if missing_args.any?
      end

      def generate_messages(prompt, arguments)
        case prompt["name"]
        when "git-commit"
          [
            {
              role: "user",
              content: {
                type: "text",
                text: "Generate a concise but descriptive commit message for these changes:\n\n#{arguments['changes']}"
              }
            }
          ]
        when "explain-code"
          language = arguments["language"] || "Unknown"
          [
            {
              role: "user",
              content: {
                type: "text",
                text: "Explain how this #{language} code works:\n\n#{arguments['code']}"
              }
            }
          ]
        else
          raise UnknownPromptError, "Prompt implementation not found for: #{prompt['name']}"
        end
      end

      def prompt_params
        params.permit(:name, arguments: {})
      end
    end
  end
RUBY

create_file 'test/integration/tools_test.rb', <<~RUBY
  require "test_helper"

  module Api
    class ToolsControllerTest < ActionDispatch::IntegrationTest
      test "list returns correctly structured tools" do
        post api_tools_path

        assert_response :success

        response_body = JSON.parse(response.body)
        tools = response_body["tools"]

        # Assert we have exactly 2 tools
        assert_equal 2, tools.length

        # Assert each tool has required structure
        tools.each do |tool|
          assert_includes tool.keys, "name"
          assert_includes tool.keys, "description"
          assert_includes tool.keys, "input_schema"

          # Verify name and description are strings
          assert tool["name"].is_a?(String)
          assert tool["description"].is_a?(String)

          # Verify input_schema is a hash
          assert tool["input_schema"].is_a?(Hash)
        end
      end
    end
  end
RUBY

create_file 'test/integration/prompts_test.rb', <<~RUBY
  require "test_helper"

  module Api
    class PromptsControllerTest < ActionDispatch::IntegrationTest
      test "list returns correctly structured prompts" do
        post api_prompts_path

        assert_response :success

        response_body = JSON.parse(response.body)
        prompts = response_body["prompts"]

        assert_equal 2, prompts.length

        prompts.each do |prompt|
          assert_includes prompt.keys, "name"
          assert_includes prompt.keys, "description"
          assert_includes prompt.keys, "arguments"
        end
      end

      test "get returns correct message structure for git-commit" do
        post api_get_prompt_path, params: {
          name: "git-commit",
          arguments: {
            changes: "Added new feature X"
          }
        }

        assert_response :success

        response_body = JSON.parse(response.body)
        messages = response_body["messages"]

        assert_equal 1, messages.length
        assert_equal "user", messages[0]["role"]
        assert_equal "text", messages[0]["content"]["type"]
        assert_includes messages[0]["content"]["text"], "Added new feature X"
      end

      test "get returns error for unknown prompt" do
        post api_get_prompt_path, params: {
          name: "unknown-prompt",
          arguments: {}
        }

        assert_response :bad_request
        assert_includes JSON.parse(response.body)["error"], "Unknown prompt"
      end

      test "get returns error for missing required arguments" do
        post api_get_prompt_path, params: {
          name: "git-commit",
          arguments: {}
        }

        assert_response :bad_request
        assert_includes JSON.parse(response.body)["error"], "Missing required arguments"
      end
    end
  end
RUBY

create_file 'test/integration/root_test.rb', <<~RUBY
  require "test_helper"

  class RootTest < ActionDispatch::IntegrationTest
    test "root displays application name and version" do
      get root_path

      assert_response :no_content # 204 status
      assert_equal 'MCP SERVER <%= Rails.application.to_s %> (<%= Rails.application.version.to_s %>)', response.body
    end
  end
RUBY

file 'VERSION', <<~PLAIN
  0.1.0
PLAIN

# Setup routes
route <<~RUBY
  namespace :api do
    post '/tools', to: 'tools#list'
    post '/call_tool', to: 'tools#call_tool'
    post '/prompts', to: 'prompts#list'
    post '/get_prompt', to: 'prompts#get'
  end
RUBY

# Main setup
after_bundle do
  # Run version config task
  rake 'app:version:config'
end
