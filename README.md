# Rails MCP Server Template

A minimal Rails API template for creating MCP (Model Context Protocol) servers.

## Features

- API-only Rails application
- Minimal dependencies
- Built-in versioning system
- Tool-based architecture
- Clean project structure

## Prerequisites

- Ruby >= 3.3.0
- Rails >= 8.0.0
- Bundler >= 2.0.0

## Quick Start

1. Create a new application using the template:

```bash
rails new your_app_name -m https://raw.githubusercontent.com/seuros/mcp_rails_template/master/template.rb --api \
  --skip-active-record \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-active-job \
  --skip-action-text \
  --skip-active-storage \
  --skip-action-cable \
  --skip-asset-pipeline \
  --skip-solid \
  --skip-hotwire \
  --skip-javascript \
  --skip-rubocop \
  --skip-dev-gems \
  --skip-kamal

```

2. Navigate to your new application:

```bash
cd your_app_name
```

3. Start the server:

```bash
rails server
```

## Project Structure

```
.
├── VERSION                 # Current version string
├── app
    ├── controllers
        └── api            # API controllers
```

## API Endpoints

- `POST /api/tools` - List available tools
- `POST /api/call_tool` - Execute a specific tool

### Tool Schema Example

```json
{
  "name": "tool_name",
  "description": "Description of what the tool does",
  "input_schema": {
    "type": "object",
    "properties": {
      "param1": {
        "type": "string",
        "description": "Description of parameter 1"
      },
      "param2": {
        "type": "integer",
        "description": "Description of parameter 2"
      },
      "param3": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "description": "Description of parameter 3"
      }
    },
    "required": ["param1"]
  }
}
```

## Version Management

The project includes three version files:

1. `VERSION` - Simple version string (e.g., "0.1.0")

To update version files:

```bash
rake app:version:config
```

## Adding New Tools

1. Create a new service in `app/services`
2. Add tool schema to `ToolsController#list`
3. Add tool handling in `ToolsController#call`

## Development

### Clean Project Setup

The template removes unnecessary Rails components to maintain a minimal footprint:
- No ActiveRecord
- No Asset Pipeline
- No ActionMailer
- No ActionCable
- No JavaScript
- No Views

### Adding Custom Tools

Example of adding a new tool:

```ruby
# In app/controllers/api/tools_controller.rb
def list
  tools = [
    {
      name: "your_tool_name",
      description: "Your tool description",
      input_schema: {
        type: "object",
        properties: {
          # Your parameters here
        },
        required: ["required_param"]
      }
    }
  ]
  render json: { tools: tools }
end
```

## Contributing

1. Fork it ( https://github.com/seuros/mcp_rails_template/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
