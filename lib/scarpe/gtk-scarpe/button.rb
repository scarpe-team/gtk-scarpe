# frozen_string_literal: true

module Scarpe::GTK
  class Button < Drawable
    def initialize(properties, parent:)
      super

      @gtk_obj = Gtk::Button.new label: @text

      # Send GTK+ click to Shoes
      @gtk_obj.signal_connect "clicked" do
        send_self_event(event_name: "click")
      end

      add_motion_events
    end

    def properties_changed(changes)
      text = changes.delete("text")
      if text
        @gtk_obj.label = text
      end

      super
    end

    def trigger(event, x = nil, y = nil)
      case event
      when "click"
        send_self_event(event_name: event)
      else
        super
      end
    end
  end
end
