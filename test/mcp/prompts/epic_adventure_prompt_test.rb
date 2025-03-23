# frozen_string_literal: true

require "test_helper"

class EpicAdventurePromptTest < ActiveSupport::TestCase
  def test_prompt_with_defaults
    prompt = EpicAdventurePrompt.new(
      hero_name: "Marissa",
      adventure_type: "mystery",
    )

    assert prompt.valid?

    response = prompt.call
    assert response.success?
    assert_equal 5, response.messages.size
  end

  def test_prompt_with_art
    prompt = EpicAdventurePrompt.new(
      hero_name: "Marissa",
      adventure_type: "mystery",
      include_art: true
    )

    assert prompt.valid?

    response = prompt.call
    assert response.success?
    assert_equal 7, response.messages.size
  end
end
