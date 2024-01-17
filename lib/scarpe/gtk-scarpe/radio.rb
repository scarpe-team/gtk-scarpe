# frozen_string_literal: true

# Gtk4 uses Checkbuttons in groups for radio buttons.
# See https://docs.gtk.org/gtk4/class.CheckButton.html

# We'll need to create button group objects.


# Some other GTK4 widgets to use:

# https://docs.gtk.org/gtk4/class.ComboBox.html - list_box (there's also an Entry flavour)
# https://docs.gtk.org/gtk4/class.Entry.html - edit_line
# https://docs.gtk.org/gtk4/class.TextView.html - edit_box

module Scarpe::GTK
  class Radio < Check
    class << self
      def add_to_group(radio_button)
        @groups ||= {}
        gn = radio_button.group_name
        group = @groups[gn]

        return if group && group.include?(radio_button)
        @groups[gn] ||= []
        @groups[gn] << radio_button
      end

      def remove_from_group(radio_button)
        @groups ||= {}
        gn = radio_button.group_name

        @groups.values.each { |group| group.delete(radio_button) }
      end

      def button_from_group(name)
        @groups ||= {}
        (@groups[name] || [])[0] # Can be nil if there are no buttons
      end
    end

    def initialize(properties, parent:)
      super

      group_button = Radio.button_from_group(group_name)
      # If there's a group button, we're in somebody else's group.
      # If there's not yet a group button, we're just in our own group.
      if group_button
        @gtk_obj.group = group_button.gtk_obj
      end

      Radio.add_to_group(self)
    end

    def group_name
      @group.to_s || (@parent ? @parent.shoes_linkable_id : "no_group")
    end

    def set_group_name(group_name)
      Radio.remove_from_group(self)
      self.group_name = group_name
      group_button = Radio.button_from_group(group_name) # This can't be this button - we removed it
      @gtk_obj.group = group_button # Conceivably nil
      Radio.add_to_group(self)
    end

    def properties_changed(changes)
      if changes.key?("group")
        set_group_name(changes.delete("group"))

        # Does changing group change whether the button is active in some cases?
        # We'll check for that here
        if @checked != !@gtk_obj.active? && !changes.key?("checked")
          # This would be a rare case where the group was changed and it changed what button was active
          @checked = @gtk_obj.active?
        end
      end

      super
    end

    def destroy_self
      Radio.remove_from_group(self)
      super
    end
  end
end
