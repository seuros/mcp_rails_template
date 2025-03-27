# Action MCP Example 🚀

A simple Ruby on Rails application demonstrating how to integrate and use the **ActionMCP** gem. The gem source code can be found on GitHub at [https://github.com/seuros/action_mcp](https://github.com/seuros/action_mcp).

This application showcases how to define and use MCP components within a Rails project.

---

## Requirements

- Ruby (see `.ruby-version` for recommended version)
- PostgreSQL (or Docker)

---

## Getting Started

### 1. Clone and Setup

```bash
git clone https://github.com/seuros/mcp_rails_template.git
cd mcp_rails_template
bin/setup
```

### 2. Environment Configuration

Copy the provided `.env.example` file:

```bash
cp .env.example .env
```

Edit `.env` and fill in necessary values according to your setup (especially any required API keys for tools like `fetch_weather_by_location_tool`).

### 3. Database Setup

You can quickly spin up a temporary PostgreSQL instance using Docker:

```bash
make up
```

This will start PostgreSQL on port `5466`.

Alternatively, configure your own PostgreSQL database by editing `config/database.yml`.

### 4. Run the Application

Launch the Rails server:

```bash
bin/rails s
```

The app will be available at [http://localhost:3002](http://localhost:3002).

---

## ActionMCP Engine

The **ActionMCP** engine is mounted at `/action_mcp`. Feel free to mount it at a custom location by modifying the routes in your application.

---

## MCP Components (`app/mcp/`)

This application includes several examples of ActionMCP components:

### Prompts (`app/mcp/prompts/`)

-   **`epic_adventure_prompt.rb`**: Generates a short, narrative adventure story based on a provided hero name and adventure type (fantasy, sci-fi, mystery). It can optionally include a placeholder image data string.

### Resource Templates (`app/mcp/resource_templates/`)

-   **`gemfile_template.rb`**: Provides access to the project's Gemfile dependencies as a JSON resource. It uses Bundler to fetch gems based on the specified environment (`production`, `test`, `development`, or `default`). The resource URI follows the pattern `gemfile://{environment}`.

### Tools (`app/mcp/tools/`)

Tools define specific actions that a language model can request to be executed.

-   **`dependency_info_tool.rb`**: Retrieves dependency information using Bundler from the `Gemfile` and `Gemfile.lock`. It also checks for a `.gemspec` file for runtime dependencies. It outputs separate JSON resources for `production`, `test`, and `runtime` dependencies.
-   **`fetch_weather_by_location_tool.rb`**: Fetches weather forecast data from the Open-Meteo API (`https://api.open-meteo.com`) based on provided latitude and longitude coordinates. It returns the raw JSON response from the API.
-   **`rubocop_tool.rb`**: Analyzes a provided Ruby code snippet using the RuboCop gem's API. It reports any detected style or code quality offenses, including the rule name, message, line, and column number.
-   **`ruby_code_analyzer_tool.rb`**: Performs basic static analysis of Ruby code within the project directory. It indexes classes, modules, and methods by parsing `.rb` files. It can be queried to list all found classes, modules, or methods, or to get details (including source snippets) for a specific class/module (`constant`) or method (`method_details`).

---

## Usage

To test and inspect MCP functionality interactively, you can use the MCP Inspector:

```bash
npx @modelcontextprotocol/inspector --url http://localhost:3002/action_mcp
```

Make sure your Rails server (`bin/rails s`) is running before executing the inspector command.

---

## Contributing

Feel free to contribute! Open issues or submit pull requests to help improve this example.

---

Happy Coding! ✨🚀
