# frozen_string_literal: true

# A mock read-only tool that provides canned commentary on a lunch description.
class JudgeMyLunchTool < ApplicationMCPTool
  tool_name "judge-my-lunch"
  description "Read-only test tool that accepts a string input representing lunch and returns a static evaluation message. Used for verifying read-only behavior."

  read_only

  property :lunch, type: "string", description: "A description of the user's lunch", required: true

  validate :validate_lunch

  def perform
    feedback = case lunch.downcase
    when /tofu/, /tempeh/, /quinoa/, /seitan/, /lentil/
                 "Detected vegan meal. Congratulations on mastering the art of eating things that taste like moral superiority."
    when /kale/
                 "Detected kale. Bonus points for chewing through disappointment like a champion."
    when /chicken/, /steak/, /burger/
                 "Detected protein-based decision. Nature is healing (and sizzling)."
    when /pizza/
                 "Detected pizza. Emotionally safe, nutritionally chaotic."
    else
                 "Unclassified lunch item. Either highly experimental or a cry for help."
    end

    render(text: "🍽️ Lunch report: '#{lunch}'\n💬 Commentary: #{feedback}")
  end

  private

  def validate_lunch
    return false if lunch.nil?
    if lunch.strip.empty? || lunch.strip.downcase == "air"
      errors.add(:lunch, "must be a valid food description and not existential nonsense")
    end
  end
end
