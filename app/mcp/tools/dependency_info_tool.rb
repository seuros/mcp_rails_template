# Project Dependency Tool, this is just a sample
class DependencyInfoTool < ApplicationMCPTool
  description "Retrieve dependency information from the project's Gemfile and gemspec files as JSON"

  def perform
    begin
      dependencies = fetch_dependencies

      # Render production dependencies
      production_deps = dependencies[:production]
      render(resource: "gemfile://production",
             text: format_as_json("production", production_deps),
             mime_type: "application/json"
      )

      # Render test dependencies
      test_deps = dependencies[:test]
      render(resource: "gemfile://test",
             text: format_as_json("test", test_deps),
             mime_type: "application/json"
      )

      # Render runtime dependencies
      runtime_deps = dependencies[:runtime]
      render(resource: "gemfile://runtime",
              text: format_as_json("runtime", runtime_deps),
              mime_type: "application/json"
      )

    rescue => e
      render(error: [ "Failed to retrieve dependencies: #{e.message}" ])
    end
  end

  private

  def fetch_dependencies
    # Use Bundler to get the actual dependencies
    gemfile = Bundler::Definition.build("Gemfile", "Gemfile.lock", {})
    # Get dependencies by group
    production_deps = gemfile.dependencies.select { |d| d.groups.include?(:default) || d.groups.include?(:production) }
                             .map do |d|
      { name: d.name, requirement: d.requirement.to_s }
    end

    test_deps = gemfile.dependencies.select { |d| d.groups.include?(:test) }
                       .map do |d|
      { name: d.name, requirement: d.requirement.to_s }
    end

    runtime_deps = []

    # Check gemspec if present for runtime dependencies
    gemspecs = Dir.glob("*.gemspec")
    if gemspecs.any?
      begin
        gemspec = Gem::Specification.load(gemspecs.first)

        # Add runtime dependencies from gemspec
        gemspec.runtime_dependencies.each do |dep|
          runtime_deps << { name: dep.name, requirement: dep.requirement.to_s }
        end

      rescue => e
        # Just log and continue if gemspec parsing fails
        puts "Warning: Could not parse gemspec: #{e.message}"
      end
    end

    # If no gemspec exists, use production deps as runtime deps
    if runtime_deps.empty?
      runtime_deps = production_deps
    end

    {
      production: production_deps,
      test: test_deps,
      runtime: runtime_deps
    }
  end

  def format_as_json(env_type, dependencies)
    # Create a JSON object with environment type and dependencies
    result = {
      environment: env_type,
      dependencies: dependencies.map { |d| { name: d[:name], requirement: d[:requirement] } }
    }

    result.to_json
  end
end
