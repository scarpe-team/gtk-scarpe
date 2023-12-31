# frozen_string_literal: true

module Scarpe::GTK
  class Button < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    def initialize(properties, parent:)
      super

      @gtk_obj = Gtk::Button.new label: @text

      # Send GTK+ click to Shoes
      @gtk_obj.signal_connect "clicked" do
        send_self_event(event_name: "click")
      end

      # TODO: hover
    end

    def put_to_canvas(canvas, context)
      x = context[:left] + (@left || 0)
      y = context[:top] + (@top || 0)
      canvas.put @gtk_obj, x, y
    end
  end
end
