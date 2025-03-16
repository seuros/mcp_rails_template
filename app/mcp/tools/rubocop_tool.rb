class RubocopTool < ApplicationMCPTool
  tool_name "rubocop"
  description "Analyze provided Ruby code using the RuboCop gem API."

  property :code, type: "string", description: "Ruby code snippet to analyze", required: true

  def perform
    require "rubocop"

    begin
      # Use the current Ruby version dynamically for future compatibility.
      ruby_version = RUBY_VERSION.to_f
      processed_source = RuboCop::ProcessedSource.new(code, ruby_version)

      # Load configuration using ConfigStore with a dummy file to get default settings.
      config_store = RuboCop::ConfigStore.new
      config = config_store.for("dummy_file.rb")

      # Mobilize the cop team using the loaded configuration.
      team = RuboCop::Cop::Team.mobilize(RuboCop::Cop::Registry.global, config)

      # Analyze the processed source.
      investigation = team.investigate(processed_source)

      # Render results based on detected offenses.
      if investigation.offenses.empty?
        render(text: "No offenses detected.")
      else
        investigation.offenses.each do |offense|
          render(text: "#{offense.cop_name}: #{offense.message}\nLine: #{offense.location.line}, Column: #{offense.location.column}")
        end
      end
    rescue => e
      render(error: ["An error occurred while running RuboCop: #{e.message}"])
    end
  end
end
