# frozen_string_literal: true

module Scarpe::GTK
  class Para < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    def initialize(properties, parent:)
      super

      @gtk_obj = Gtk::Label.new
      @gtk_obj.set_markup child_markup
    end

    def child_markup
      # The children should be only text strings or TextDrawables.
      @text_items.map do |text_item|
        if text_item.is_a?(String)
          text_item.gsub("\n", "<br>")
        else
          # Should be a TextDrawable
          text_item.to_markup
        end
      end.join
    end

    def put_to_canvas(canvas, context)
      x = context[:left] + (@left || 0)
      y = context[:top] + (@top || 0)
      canvas.put @gtk_obj, x, y
    end
  end
end
