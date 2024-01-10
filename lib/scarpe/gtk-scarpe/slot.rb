# frozen_string_literal: true

module Scarpe::GTK
  # The GTK::Slot class is for drawables that can contain other drawables.
  class Slot < Drawable
    # The children of this drawable, if it is a slot or can otherwise have children
    attr_reader :children

    alias :pos_children :children

    def initialize(properties, parent:)
      @children = []

      unless @position_as
        position_as(self.class.name.split("::")[-1])
      end

      super

      # Slots don't currently need or use GTK+ objects - they're just for positioning
    end

    # Do not call directly, use set_parent
    def remove_child(child)
      unless @children.include?(child)
        @log.error("remove_child: no such child(#{child.inspect}) for parent(#{parent.inspect})!")
      end
      @children.delete(child)
    end

    # Do not call directly, use set_parent
    def add_child(child)
      @children << child

      # If we add a child, we should redraw ourselves
      #needs_update!
    end

    def put_to_canvas(canvas, context)
      ctx = context.dup
      ctx[:left] += @left if @left
      ctx[:top] += @top if @top
      @children.each do |child|
        child.put_to_canvas canvas, ctx
      end
    end
  end

  class Flow < Slot
  end

  class Stack < Slot
  end

  # left: 0, top: 0
  class DocumentRoot < Slot
    def initialize(properties, parent:)
      position_as("Flow")
      @gtk_obj = Gtk::Fixed.new
      super
    end
  end
end
