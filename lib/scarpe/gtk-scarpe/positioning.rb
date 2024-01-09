# frozen_string_literal: true

# In some display services, like GTK+, we'll need to do our own
# positioning - figure out the coordinates and size of each
# drawable based on their type and styles, and the current
# window/screen size. Much like Calzini, which renders to
# HTML, this can "render" to pixel measurements.
module Scarpe; end

# Drawable classes can include Scarpe::Positioning and implement the
# methods it needs. There have to be some kind of "native" methods
# because we can't figure out for ourselves how much space each font
# or native drawable object needs (e.g. checkbox, progress bar.)
#
# This is a separate module to make it easy to "detach" the Shoes
# positioning logic from any specific system. Shoes positioning isn't
# as flexible and comprehensive as CSS and doesn't have the same
# abstractions as GTK+. Sometimes it makes you use Ruby logic or more
# slots if you want a specific effect. That's good! It makes it
# easier for us to implement. And it means we want to be able to
# calculate just the Shoes logic, separate from the underlying display.
module Scarpe::Positioning
  # These are the fundamental Drawable positioning types that are recognized
  # by Scarpe::Positioning. It's possible to pass other values to position_as(),
  # but they all act like one of these. For instance, the value "Drawable" is
  # used to mean "some Drawable, don't do anything special with it" for drawables
  # that just act like a minimum-size box, such as Para, Button, EditBox,
  # Progress and so on. The size of the box is calculated via pos_minimum_size,
  # but after that the drawables all behave identically.
  SC_POS_DRAWABLE_TYPES = ["Stack", "Flow", "Drawable"]

  # There are only a few different ways that Drawables position themselves. Most
  # Drawables have a minimum rectangular size or exist outside the flow logic,
  # depending on their style values. A Slot acts like a Stack or Flow normally,
  # even if it's a Widget or DocumentRoot. A Banner or Caption acts the same
  # as a Para in every way.
  POS_DRAWABLE_ALIASES = {
    "DocumentRoot" => "Flow",
    "Widget" => "Flow",
    "Button" => "Drawable",
    "Para" => "Drawable",
  }

  # If you include Scarpe::Positioning in your Drawable class, you'll
  # probably call position_as in your initialize() method. The
  # argument should be one of {SC_POS_DRAWABLE_TYPES}.
  def position_as(t)
    unless SC_POS_DRAWABLE_TYPES.include?(t.to_s) || POS_DRAWABLE_ALIASES.key?(t.to_s)
      STDERR.puts "Warning: unknown Drawable type #{t.inspect} in Scarpe::Positioning!"
      STDERR.puts "Supply one of the known types or implement the one you want!"
      STDERR.puts "#{SC_POS_DRAWABLE_TYPES.inspect}"
      raise "Implement me!"
    end
    t = t.to_s
    @position_as = POS_DRAWABLE_ALIASES[t] || t
    raise("Internal error! Should be unreachable!") unless @position_as
  end

  # The minimum_size method should return a width, height pair of integers
  # for the minimum width and height that this drawable can comfortably
  # occupy. If Shoes allocates less space than this, the widget will be cut
  # off, look wrong or otherwise be "squashed" somehow. The display service
  # may or may not handle this squashing gracefully.
  def pos_minimum_size
    raise "Implement pos_minimum_size() in your subclass!"
  end

  # When a drawable is created in the display service, it receives a hash
  # of properties (styles) which may be updated later. Scarpe::Positioning
  # will often need to know property values, such as the text and font for
  # a button or the requested width of a Stack. This method will be called
  # to query those values. It should return a Hash with String keys.
  #
  # @return Hash[String] the Hash of property values
  def pos_properties
    raise "Implement pos_properties() in your subclass! #{self.inspect}"
  end

  # When a drawable is created in the display service, it receives a hash
  # of properties (styles) which may be updated later. Scarpe::Positioning
  # will often need to know property values, such as the text and font for
  # a button or the requested width of a Stack. This method will be called
  # to query a single property value. If you don't implement it,
  # Scarpe::Positioning will query all the properties and then get just the
  # one it wants, which is sometimes very inefficient and sometimes fine.
  #
  # @param name [String] the property to query.
  # @return the value of the named property
  def pos_property(name)
    pos_properties[name]
  end

  # Return a list of children, which should also include/implement
  # Scarpe::Positioning.
  def pos_children
    raise "Implement pos_children() in your subclass!"
  end

  # Calculate the layout of ourselves and our children, if any.
  # The initial app context will have the app's top-level width
  # and height, and each slot will receive its parent's width
  # and height in the context, then pass the appropriate slot
  # width and height (its own) to its children.
  #
  # @return [Hash<String,Object>] a Hash of calculated values like width, height, top and left
  def calculate_layout(ctx)
    unless @position_as
      raise "Must declare what element type to position as! #{self.inspect}"
    end

    pw = pos_property("width")
    ph = pos_property("height")
    pt = pos_property("top")
    pl = pos_property("left")

    # If there is a requested width, height, top or left, use it
    w = pw && req_to_size(pw, ctx["width"])
    h = ph && req_to_size(ph, ctx["height"])
    t = pt && req_to_size(pt || 0, ctx["height"])
    l = pl && req_to_size(pl || 0, ctx["width"])

    # Failing that, if it's a Drawable with a native height or width, use that
    if @position_as == "Drawable" && (!w || !h)
      min_w, min_h = pos_minimum_size
      w ||= min_w
      h ||= min_h
    end

    out_ctx = {
      "top" => t || ctx["top"] || 0,
      "left" => l || ctx["left"] || 0,
      "width" => w,
      "height" => h,
    }

    if @position_as == "Stack"
      pc = pos_children
      child_layouts = []

      next_top = out_ctx["top"]
      pc.each do |child|
        child_layout = child.calculate_layout(out_ctx.merge("top" => next_top))
        child_layouts << child_layout
        next_top = child_layout["top"] + child_layout["height"]
      end

      out_ctx["children"] = child_layouts
    elsif @position_as == "Flow"
      pc = pos_children
      child_layouts = []

      next_top = out_ctx["top"]
      next_left = out_ctx["left"]
      far_left = out_ctx["left"]
      row_height = 0

      pc.each do |child|
        child_layout = child.calculate_layout(out_ctx.merge("top" => next_top, "left" => next_left))
        if child_layout["left"] + child_layout["width"] > out_ctx["width"] && next_left != far_left
          # Stack vertically - no space left to the right
          child_layout["left"] = far_left
          child_layout["top"] = next_top + row_height
          next_top = next_top + row_height
          row_height = child_layout["height"]
          next_left = child_layout["left"] + child_layout["width"]
        else
          # Stack horizontally
          row_height = child_layout["height"] if child_layout["height"] > row_height
          next_left = child_layout["left"] + child_layout["width"]
        end
        child_layouts << child_layout
      end

      # out_ctx has the slot's top, left, width and height
      out_ctx["children"] = child_layouts
    end

    if w && h
      return(out_ctx)
    end

    raise "Implement me! #{self.inspect}"
  end

  private

  # Turn a size request -- like 37, or 0.4, or "39%" -- into a
  # height or width in pixels, given the current context
  # height or width.
  def req_to_size(req, context_size)
    case req
    when nil, Integer
      if req < 0
        m = context_size + req
        return (m > 0 ? m : 0)
      end
      return req
    when Float
      if req < 0
        req = 1.0 + req
      end
      return context_size * req
    when String
      if req[-1] == "%"
        r = req.to_f / 100.0
        if r < 0
          r = 1.0 + r
        end
        return context_size * r
      end
      raise "Unexpected size-request object: #{req.inspect}"
    else
      raise "Unexpected size-request object: #{req.inspect}"
    end
  end

  # This returns the requested margin for left/top/right/bottom, but it could be
  # a float (percentage) or negative number that requires further width-dependent
  # calculation.
  def requested_margin(ctx_width, ctx_height)
    # Get margin default
    md = pos_property("margin") || 0

    [
      req_to_size(pos_property("margin_left") || md, context_width),
      req_to_size(pos_property("margin_top") || md, context_height),
      req_to_size(pos_property("margin_right") || md, context_width),
      req_to_size(pos_property("margin_bottom") || md, context_height),
    ]
  end

  public
end
