source "https://rubygems.org"

# Use ActiveRecord for database ORM and Railties for the framework's core
gem "activerecord", ENV.fetch("RAILS_VERSION", "~> 8.1.0")
gem "railties", ENV.fetch("RAILS_VERSION", "~> 8.1.0")

# Support for controller actions
gem "actionview", ENV.fetch("RAILS_VERSION", "~> 8.1.0")
gem "activejob", ENV.fetch("RAILS_VERSION", "~> 8.1.0")

# Use PostgreSQL as the database for Active Record
gem "pg"
# Use Falcon for web and MCP server (better for streaming/async)
gem "falcon"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache and Action Cable
gem "solid_cache"
gem "solid_cable"

gem "actionmcp"
gem "solid_mcp", "~> 0.5"

# Use bcrypt for has_secure_password
gem "bcrypt", "~> 3.1.7"

# JWT for authentication tokens
gem "jwt", "~> 3.1"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  gem "foreman"
end

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Ruby language server support
gem "ruby-lsp"
gem "ruby-lsp-rails"
