# frozen_string_literal: true

class ClientInfoTool < ApplicationMCPTool
  tool_name "client_info"
  description "Returns the MCP client name and version that initiated this session"

  def perform
    client_info = session&.client_info || {}

    render text: "Client: #{client_info['name'] || 'unknown'}, Version: #{client_info['version'] || 'unknown'}"
  end
end
