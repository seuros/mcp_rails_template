# frozen_string_literal: true

# This migration comes from action_mcp (originally 20251126000001)
class AddContinuationStateToActionMCPSessionTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :action_mcp_session_tasks, :continuation_state, :json, default: {}
    add_column :action_mcp_session_tasks, :progress_percent, :integer
    add_column :action_mcp_session_tasks, :progress_message, :string
    add_column :action_mcp_session_tasks, :last_step_at, :datetime
  end
end
