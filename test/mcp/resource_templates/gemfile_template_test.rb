# frozen_string_literal: true

require "test_helper"

class GemfileTemplateTest < ActiveSupport::TestCase
  def test_gemfile_template
    template = GemfileTemplate.new(
      environment: "development"
    )

    resource = template.call

    assert resource.present?
  end
end
