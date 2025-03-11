# Action MCP Example 🚀

A simple Ruby on Rails application demonstrating how to integrate and use **ActionMCP**.

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

Edit `.env` and fill in necessary values according to your setup.

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

By default, the **ActionMCP** engine is mounted at `/action_mcp`. Feel free to mount it at a custom location by modifying the routes in your application.

---

## Usage

The app includes a simple tool to lint Ruby code using **RuboCop** through ActionMCP.

To test and inspect MCP functionality interactively, run:

```bash
npx @modelcontextprotocol/inspector
```

---

## Contributing

Feel free to contribute! Open issues or submit pull requests to help improve this example.

---

Happy Coding! ✨🚀
