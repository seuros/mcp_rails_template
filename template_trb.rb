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
gem 'dry-validation'
gem 'representable'
gem 'reform'
gem 'multi_json'

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
create_file 'config/mcp_tools.yml', <<~'YAML'
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

# Create tools controller
create_file 'app/controllers/api/tools_controller.rb', <<~RUBY
  module Api
    class ToolsController < BaseController
      def list
        tools = Rails.application.config_for(:mcp_tools)["tools"]
        render json: { tools: tools }
      end

      def call_tool
        tool_name = tool_params[:name]
        case tool_name
        when "tool_name"
          raise "Not implemented"
          render json: { result: result }
        when "convert_time"
          args = tool_params[:arguments]
          source_timezone = args[:source_timezone]
          time = args[:time]
          target_timezone = args[:target_timezone]
          raise "Not implemented"
          render json: { result: result }
        else
          render_error "Unknown tool: \#{tool_name}", :bad_request
        end
      end

      private

      def tool_params
        params.permit(:name, arguments: [:source_timezone, :time, :target_timezone])
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

# Create Service base
create_file 'app/services/tool_base_service.rb', <<~RUBY
  class ToolBaseService < Trailblazer::Operation

  end
RUBY

# Create Base form
create_file 'app/forms/tool_base_form.rb', <<~RUBY
  require "reform/form/coercion"
  require "reform/form/dry"
  class ToolBaseForm < Reform::Form
    feature Dry
    feature Coercion
    module Types
      include Dry.Types()
    end
  end
RUBY

# Create version file
file 'VERSION', <<~RUBY
  0.1.0
RUBY

# Setup routes
route <<~RUBY
  namespace :api do
    post '/tools', to: 'tools#list'
    post '/call_tool', to: 'tools#call_tool'
  end
RUBY

# Main setup
after_bundle do
  # Run version config task
  rake 'app:version:config'
  # Run rubocop with autocorrect
  run 'bundle exec rubocop -A'
end
