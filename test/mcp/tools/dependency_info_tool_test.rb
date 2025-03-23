# frozen_string_literal: true

require "test_helper"

class DependencyInfoToolTest < ActiveSupport::TestCase
  def test_gemfile_template
    tool = DependencyInfoTool.new # it takes no arguments

    response = tool.call
    assert response.success?
    assert_equal 3, response.size # each environment has 1 block
  end
end
