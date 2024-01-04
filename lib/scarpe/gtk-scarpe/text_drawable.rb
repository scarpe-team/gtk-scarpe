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
        props: @props,
      }
    end

    # How are we going to do styling?
    def vis_item_to_markup(vis_item)
      raise "Set tag! #{vis_item.inspect}" unless vis_item[:tag]

      "<#{vis_item[:tag]}>" +
      vis_item[:items].map do |sub_item|
        sub_item.is_a?(String) ? sub_item : vis_item_to_markup(sub_item)
      end.join +
      "</#{vis_item[:tag]}>"
    end

    def to_markup
      vis_item_to_markup(visual_item)
    end

    class << self
      def tagged_text_drawable(shoes_tag, gtk_tag = nil)
        gtk_tag ||= shoes_tag
        display_class_name = shoes_tag.capitalize
        drawable_class = Class.new(Scarpe::GTK::TextDrawable) do
          # The gtk_tag local var isn't visible here, need to pass it a different way
          class << self
            attr_accessor :gtk_tag
          end

          def visual_item
            h = super
            h[:tag] = self.class.gtk_tag
            h
          end
        end

        Scarpe::GTK.const_set(display_class_name, drawable_class)
        drawable_class.gtk_tag = gtk_tag
      end
    end
  end
end

# Do any of these need variant styles or tags? Ins is a Lacci-styled span in Webview.
[
  [:code, :tt],
  [:del],
  [:em, :i],
  [:strong, :b],
  [:span],
  [:sub],
  [:sup],
  [:ins]
].each do |shoes_tag, pango_tag|
  Scarpe::GTK::TextDrawable.tagged_text_drawable(shoes_tag, pango_tag)
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
