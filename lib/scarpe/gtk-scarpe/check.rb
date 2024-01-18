# frozen_string_literal: true

module Scarpe::GTK
  class Check < Drawable
    def initialize(properties, parent:)
      super

      @gtk_obj = Gtk::CheckButton.new
      @gtk_obj.active = true if @checked

      # Send GTK+ click to Shoes
      @gtk_obj.signal_connect "toggled" do
        new_val = @gtk_obj.active?
        if new_val != @checked
          send_self_event(event_name: "click")
        end
      end

      add_motion_events
    end

    def properties_changed(changes)
      if changes.key?("checked")
        new_val = changes.delete("checked")
        if @gtk_obj.active? != new_val
          @gtk_obj.active = new_val
        end
      end

      super
    end
  end
end
