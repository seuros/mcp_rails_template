# app/tools/rubocop_tool.rb

class RubocopTool < ApplicationTool
  tool_name "rubocop"
  description "Analyze provided Ruby code using the RuboCop gem API."

  property :code, type: "string", description: "Ruby code snippet to analyze", required: true

  def call
    require "rubocop"

    begin
      # Create a ProcessedSource from the provided code using Ruby version 3.0.
      processed_source = RuboCop::ProcessedSource.new(code, 3.0)

      # Load configuration using ConfigStore. A dummy file path is provided to load default settings.
      config_store = RuboCop::ConfigStore.new
      config = config_store.for("dummy_file.rb")

      # Mobilize the cop team with the loaded configuration.
      team = RuboCop::Cop::Team.mobilize(RuboCop::Cop::Registry.global, config)

      # Investigate the processed source to obtain an InvestigationReport.
      investigation = team.investigate(processed_source)

      # Build the output from the offenses.
      if investigation.offenses.empty?
        render text: "No offenses detected."
      else
        output = investigation.offenses.map do |offense|
          "#{offense.cop_name}: #{offense.message}\nLine: #{offense.location.line}, Column: #{offense.location.column}"
        end.join("\n\n")
        render text: output
      end
    rescue => e
      render error: "An error occurred while running RuboCop: #{e.message}"
    end
  end
end
