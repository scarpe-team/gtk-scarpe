# frozen_string_literal: true

module Scarpe::GTK
  class Button < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    attr_reader :gtk_obj # Needed for triggering clicks in tests

    def initialize(properties, parent:)
      super

      @gtk_obj = Gtk::Button.new label: @text

      # Send GTK+ click to Shoes
      @gtk_obj.signal_connect "clicked" do
        send_self_event(event_name: "click")
      end

      # TODO: hover
    end

    def properties_changed(changes)
      text = changes.delete("text")
      if text
        @gtk.obj.text = text
      end

      super
    end
  end
end
