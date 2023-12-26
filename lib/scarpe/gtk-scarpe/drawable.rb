# frozen_string_literal: true

module Scarpe::GTK
  # The GTK::Drawable class connects the GTK+ drawables with the
  # Shoes/Lacci drawables. It connects what happens in GTK+ with
  # what happens in Shoes.
  class Drawable < Shoes::Linkable
    include Shoes::Log

    class << self
      # Return the corresponding Scarpe::GTK class for a particular Shoes class name
      def display_class_for(shoes_class_name)
        scarpe_class = Shoes.const_get(shoes_class_name)
        unless scarpe_class.ancestors.include?(Shoes::Linkable)
          raise Scarpe::InvalidClassError, "Gtk-scarpe can only get display classes for Shoes " +
            "linkable drawables, not #{shoes_class_name.inspect}!"
        end

        klass = Scarpe::GTK.const_get(shoes_class_name.split("::")[-1])
        if klass.nil?
          raise Scarpe::MissingClassError, "Couldn't find corresponding gtk-scarpe class for #{shoes_class_name.inspect}!"
        end

        klass
      end
    end

    # The Shoes ID for the Shoes drawable this display-drawable corresponds to
    attr_reader :shoes_linkable_id

    # The display-drawable parent (or nil if no parent)
    attr_reader :parent

    def initialize(properties)
      log_init("GTK::Drawable")

      @shoes_style_names = properties.keys.map(&:to_s) - ["shoes_linkable_id"]

      @shoes_linkable_id = properties["shoes_linkable_id"] || properties[:shoes_linkable_id]
      unless @shoes_linkable_id
        raise Scarpe::MissingAttributeError, "Could not find property shoes_linkable_id in #{properties.inspect}!"
      end

      # Set the Shoes styles as instance variables
      properties.each do |k, v|
        next if k == "shoes_linkable_id"

        instance_variable_set("@" + k.to_s, v)
      end

      # Must call this before we can bind events
      super(linkable_id: @shoes_linkable_id)

      # Shoes doesn't normally change parents after the drawable is initially created.
      bind_shoes_event(event_name: "parent", target: shoes_linkable_id) do |new_parent_id|
        display_parent = DisplayService.instance.query_display_drawable_for(new_parent_id)
        if @parent != display_parent
          set_parent(display_parent)
        end
      end

      # When Shoes drawables change properties, we get a change notification here
      bind_shoes_event(event_name: "prop_change", target: shoes_linkable_id) do |prop_changes|
        prop_changes.each do |k, v|
          instance_variable_set("@" + k, v)
        end
        properties_changed(prop_changes)
      end

      bind_shoes_event(event_name: "destroy", target: shoes_linkable_id) do
        destroy_self
      end
    end

    def shoes_styles
      p = {}
      @shoes_style_names.each do |prop_name|
        p[prop_name] = instance_variable_get("@#{prop_name}")
      end
      p
    end

    # Properties_changed will be called automatically when properties change.
    # The drawable should delete any changes from the Hash that it knows how
    # to incrementally handle, and pass the rest to super. If any changes
    # go entirely un-handled, a full redraw of that drawable will be scheduled.
    # This exists to be overridden by children watching for changes.
    #
    # @param changes [Hash] a Hash of new values for properties that have changed
    def properties_changed(changes)
      # For each subclass need to handle the known properties and then call super

      raise("Somebody didn't handle a property change!") unless changes.empty?
    end

    # Give this drawable a new parent, including managing the appropriate child lists for parent drawables.
    def set_parent(new_parent)
      @parent&.remove_child(self)
      new_parent&.add_child(self)
      @parent = new_parent
    end

    # A shorter inspect text for prettier irb output
    def inspect
      "#<#{self.class}:#{self.object_id} @shoes_linkable_id=#{@shoes_linkable_id} @children=#{@children.inspect}>"
    end

    # Removes the element from both the Ruby Drawable tree and the HTML DOM.
    # Unsubscribe from all Shoes events.
    def destroy_self
      @parent&.remove_child(self)
      unsub_all_shoes_events
      # TODO: remove properly
    end
  end
end
