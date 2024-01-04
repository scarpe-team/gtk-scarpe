# frozen_string_literal: true

module Scarpe::GTK
  # TextDrawables are little data objects. They do fairly little, mostly.
  # They do *not* inherit from Scarpe::GTK::Drawable. Note that
  # a Para or EditLine is *not* a TextDrawable. It's a Drawable that
  # contains text. Normal drawables do a lot more signal handling and
  # need to be part of the Drawable tree, with corresponding GTK+ objects.
  # TextDrawables are just a source of markup and styling data for GTK+
  # or Pango.
  class TextDrawable < Shoes::Linkable
    def initialize(properties, parent:)
      super()

      @props = properties
      @parent = parent
      @shoes_linkable_id = properties.delete("shoes_linkable_id")
      unless @shoes_linkable_id
        raise Scarpe::MissingAttributeError, "Could not find property shoes_linkable_id in #{properties.inspect}!"
      end

      # When Shoes drawables change properties, we get a change notification here
      bind_shoes_event(event_name: "prop_change", target: @shoes_linkable_id) do |prop_changes|
        raise "Implement me!"
      end

      bind_shoes_event(event_name: "destroy", target: @shoes_linkable_id) do
        raise "Implement me!"
      end
    end

    def self.color_to_rgb(c)
      return "#000000FF" if c == ""
      return c if c.is_a?(String)
      return nil if c.nil?

      if c.is_a?(Array) && c[0].is_a?(Integer)
        r, g, b, a = *c
        if r.is_a?(Float)
          r = (r * 255.0).to_i
          g = (g * 255.0).to_i
          b = (b * 255.0).to_i
          a = ((a || 1.0) * 255.0).to_i
        end

        r = r.clamp(0, 255)
        g = g.clamp(0, 255)
        b = b.clamp(0, 255)
        a = a.clamp(0, 255)

        return "#%0.2X%0.2X%0.2X%0.2X" % [r, g, b, a]
      end

      raise "Implement me! Color conversion: #{c.inspect}"
    end

    def self.shoes_properties_to_pango_attributes(p)
      out = {}
      p.each do |prop, val|
        next if val.nil?
        next if prop == "text_items"

        case prop
        when "stroke"
          out[:foreground] = color_to_rgb(val)
        when "fill"
          out[:background] = color_to_rgb(val)
        when "align", "font", "strikecolor", "underline", "undercolor", "size"
          # Not yet handled...
          # Note: Pango RGB color specs are allowed to have a fourth component for alpha
        else
          puts "Need to add Shoes text property handler for #{prop.inspect}!"
        end
      end

      out
    end

    def pango_attributes
      p_props = self.class.shoes_properties_to_pango_attributes(@props)
      self.class.default_pango_attributes.merge(p_props)
    end

    # Get an alternating list of Strings and TextDrawables for the text content.
    def items_to_display_children(items)
      return [] if items.nil?

      items.map do |item|
        if item.is_a?(String)
          item
        else
          DisplayService.instance.query_display_drawable_for(item)
        end
      end
    end

    # This is pretty similar to to_calzini_hash -- it's the Shoes visual data for the
    # text and formatting.
    def visual_item
      vis_items = items_to_display_children(@props["text_items"]).map do |item|
        if item.respond_to?(:visual_item)
          item.visual_item
        elsif item.is_a?(String)
          item
        else
          # This should normally be filtered out in Lacci, long before we see it
          raise "Unrecognized item in TextDrawable! #{item.inspect}"
        end
      end

      {
        items: vis_items,
        id: @linkable_id,
        tag: nil, # The parent TextDrawable doesn't know what tag yet
        props: pango_attributes,
      }
    end

    # How are we going to do styling?
    def vis_item_to_markup(vis_item)
      props = vis_item[:props].map { |k, v| " #{k}=\"#{v}\""}.join("")
      "<span#{props}>" +
      vis_item[:items].map do |sub_item|
        sub_item.is_a?(String) ? sub_item : vis_item_to_markup(sub_item)
      end.join +
      "</span>"
    end

    def to_markup
      vis_item_to_markup(visual_item)
    end

    class << self
      attr_accessor :default_pango_attributes

      def tagged_text_drawable(shoes_tag, pango_attributes)
        display_class_name = shoes_tag.capitalize
        drawable_class = Class.new(Scarpe::GTK::TextDrawable)
        Scarpe::GTK.const_set(display_class_name, drawable_class)

        drawable_class.default_pango_attributes = pango_attributes
      end
    end
  end
end

# Map Shoes tag names to default Pango formatting.
[
  [:code, { font_family: "Monospace" }],
  [:del, { strikethrough: true }],
  [:em, { style: "italic" }],
  [:strong, { weight: "bold" }],
  [:span, {}],
  [:sub, { font_scale: "subscript", baseline_shift: "subscript" }],
  [:sup, { font_scale: "superscript", baseline_shift: "superscript" }],
  [:ins, { underline: "single" }]
].each do |shoes_tag, pango_attrs|
  Scarpe::GTK::TextDrawable.tagged_text_drawable(shoes_tag, pango_attrs)
end

# How are we doing links?
module Scarpe::GTK
  class Link < TextDrawable
    def visual_items
      h = super
      h[:tag] = "a"
      h
    end
  end
end
