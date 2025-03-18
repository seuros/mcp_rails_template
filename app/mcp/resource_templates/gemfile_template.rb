class GemfileTemplate < ApplicationMCPResTemplate
  description "Access Gemfile dependency information"
  uri_template "gemfile://{environment}"
  mime_type "application/json"

  parameter :environment, description: "Environment type (production, test, development, default)", required: true
  validates :environment, inclusion: { in: %w[production test development default] }

  def resolve
    # Get all gems from the Gemfile
    gems = fetch_gems_for_environment(environment)

    # Return nil if no gems found for the environment
    return nil if gems.empty?
    # Create a resource with all gems for the requested environment
    ActionMCP::Content::Resource.new(
      "gemfile://#{environment}",
      self.class.mime_type,
      text: gems.to_json
    )
  end

  private

  def fetch_gems_for_environment(env)
    # Use Bundler to get the actual dependencies
    gemfile = Bundler::Definition.build("Gemfile", "Gemfile.lock", {})

    case env
    when "production"
      gemfile.dependencies
             .select { |d| d.groups.include?(:default) || d.groups.include?(:production) }
             .map { |d| { name: d.name, requirement: d.requirement.to_s } }
    when "test"
      gemfile.dependencies
             .select { |d| d.groups.include?(:test) }
             .map { |d| { name: d.name, requirement: d.requirement.to_s } }
    when "development"
      gemfile.dependencies
             .select { |d| d.groups.include?(:development) }
             .map { |d| { name: d.name, requirement: d.requirement.to_s } }
    when "all"
      # Return all gems regardless of group
      gemfile.dependencies
             .map { |d| { name: d.name, requirement: d.requirement.to_s, groups: d.groups.map(&:to_s) } }
    else
      []
    end
  end
end
