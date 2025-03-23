# frozen_string_literal: true

require "test_helper"

class RubocopToolTest < ActiveSupport::TestCase
  def test_call
    tool = RubocopTool.new(
      code: "class Foo; end"
    )

    response = tool.call
    assert response.success?
    assert_equal 1, response.size

    offense = response.first
    assert_match "Layout/TrailingEmptyLines", offense.text.to_s
  end
end
