# frozen_string_literal: true

module Scarpe::GTK
  # The GTK::Slot class is for drawables that can contain other drawables.
  class Slot < Drawable
    # The children of this drawable, if it is a slot or can otherwise have children
    attr_reader :children

    protected

    # Do not call directly, use set_parent
    def remove_child(child)
      @children ||= []
      unless @children.include?(child)
        @log.error("remove_child: no such child(#{child.inspect}) for"\
          " parent(#{parent.inspect})!")
      end
      @children.delete(child)
    end

    # Do not call directly, use set_parent
    def add_child(child)
      @children ||= []
      @children << child

      # If we add a child, we should redraw ourselves
      #needs_update!
    end

    public

  end

  class Flow < Slot
  end

  class Stack < Slot
  end

  class DocumentRoot < Slot
  end
end
