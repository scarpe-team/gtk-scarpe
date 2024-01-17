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

      # TODO: figure out which of these events, if any, are set and only include
      # a controller if needed?
      @hover_controller = Gtk::EventControllerMotion.new
      @gtk_obj.add_controller @hover_controller
      @hover_controller.signal_connect "enter" do
        send_self_event(event_name: "hover")
      end
      @hover_controller.signal_connect "leave" do
        send_self_event(event_name: "leave")
      end
      @hover_controller.signal_connect "motion" do |_controller, x, y|
        send_self_event(x, y, event_name: "motion")
      end
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
