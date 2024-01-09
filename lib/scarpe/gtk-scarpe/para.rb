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
          DisplayService.instance.query_display_drawable_for(text_item).to_markup
        end
      end.join
    end

    def properties_changed(changes)
      items = changes.delete("text_items")
      if items
        @gtk_obj.set_markup child_markup
      end

      super
    end
  end
end
