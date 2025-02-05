# Rails MCP Server Template

A minimal Rails API template for creating MCP (Model Context Protocol) servers with robust tool execution capabilities.

## Features

- API-only Rails application optimized for performance
- Minimal dependencies with stripped-down configuration
- Built-in versioning system
- Tool-based architecture with error handling
- Clean project structure
- Standardized API responses
- Comprehensive error handling system

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
│   ├── controllers
│   │   └── api           # API controllers
│   │       ├── base_controller.rb
│   │       └── tools_controller.rb
├── config
│   └── mcp_tools.yml     # Tool definitions
└── test
    └── integration       # Integration tests
```

## API Endpoints

### List Available Tools
- **Endpoint**: `POST /api/tools`
- **Response**: List of available tools with their schemas

### Execute Tool
- **Endpoint**: `POST /api/call_tool`
- **Parameters**:
  ```json
  {
    "name": "tool_name",
    "arguments": {
      "param1": "value1",
      "param2": "value2"
    }
  }
  ```
- **Response**: Tool execution result or error message

### Error Handling

The API implements a comprehensive error handling system with specific error types:

- `UnknownToolError`: When requesting a non-existent tool
- `ToolExecutionError`: When tool execution fails
- `StandardError`: For unexpected internal errors

Error responses follow this format:
```json
{
  "error": "Error message description",
  "status": 400  // HTTP status code
}
```

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

The project uses a simple version management system:

1. `VERSION` - Simple version string (e.g., "0.1.0")

To update version files:

```bash
rake app:version:config
```

## Adding New Tools

1. Define the tool in `config/mcp_tools.yml`:
```yaml
tools:
  - name: your_tool_name
    description: Your tool description
    input_schema:
      type: object
      properties:
        param1:
          type: string
          description: Description of parameter 1
      required:
        - param1
```

2. Add the tool implementation in `ToolsController`:
```ruby
def execute_your_tool_name(args)
  # Tool implementation
  {
    result: "Tool execution result"
  }
end
```

## Development

### Clean Project Setup

The template removes unnecessary Rails components to maintain a minimal footprint:
- No ActiveRecord
- No Asset Pipeline
- No ActionMailer
- No ActionCable
- No JavaScript
- No Views

### Testing

The project includes integration tests for the tools framework. Run tests with:

```bash
rails test
```

Test examples are provided for:
- Tool listing
- Tool execution
- Error handling
- Parameter validation

## Contributing

1. Fork it ( https://github.com/seuros/mcp_rails_template/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
