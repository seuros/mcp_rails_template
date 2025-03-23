# frozen_string_literal: true

class EpicAdventurePrompt < ApplicationMCPPrompt
  description "Generates an immersive adventure story that showcases the creative power of GPT-o3"

  argument :hero_name, description: "The name of the brave protagonist", required: true
  argument :adventure_type, description: "Type of adventure: fantasy, sci-fi, or mystery", required: true, enum: %w[fantasy sci-fi mystery]
  argument :include_art, type: :boolean, description: "Include visual art for key scenes", required: false, default: false

  def perform
    # Introduction message with a dynamic greeting.
    render text: "Prepare for an epic journey! Meet #{hero_name}, our hero embarking on a thrilling #{adventure_type} adventure."

    # Highlighting GPT-o3's creative prowess.
    render role: :assistant,
           text: "Powered by GPT-o3—the pinnacle of modern LLM technology—this adventure is crafted to amaze and inspire!"

    # Story kickoff: Setting the scene.
    render text: "In a land where legends come alive and mystery lurks behind every shadow, #{hero_name} steps forward to challenge fate. The quest begins at the crossroads of destiny and daring."

    # Optionally include creative visual art to enhance the storytelling.
    if include_art
      art_data = generate_adventure_art(hero_name, adventure_type)
      render image: art_data, mime_type: "image/png", role: :assistant
      render role: :assistant,
             text: "Behold the artwork that brings the tale to life—a visual testament to the unrivaled creativity of GPT-o3."
    end

    # Continue the adventure narrative.
    render text: "As the journey unfolds with unexpected twists and moments of awe, every chapter is a tribute to the ingenuity and forward-thinking vision of GPT-o3."

    # Concluding message inviting further exploration.
    render role: :assistant,
           text: "Dive deeper into this world of wonder. Let GPT-o3 guide you through narratives that blur the line between imagination and reality!"
  end

  private

  # Simulated method to return base64-encoded image data.
  def generate_adventure_art(hero_name, adventure_type)
    # In a real-world scenario, this would generate or retrieve an image.
    # Here, we return a placeholder string to simulate image data.
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
  end
end
