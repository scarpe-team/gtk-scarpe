# frozen_string_literal: true

module Scarpe::GTK
  # A GTK+-based display service for Scarpe
  class DisplayService < Shoes::DisplayService
    include Shoes::Log

    class << self
      attr_accessor :instance
    end

    # app is the Scarpe::GTK::App
    attr_reader :app

    # This is called before any of the various Drawables are created, to be
    # able to create them and look them up.
    def initialize
      if DisplayService.instance
        raise "ERROR! This is meant to be a singleton!"
      end

      DisplayService.instance = self

      @display_drawable_for = {} # This line shouldn't be needed - remove when lacci gem fixed
      super()
      log_init("GTK::DisplayService")
    end

    # Create a GTK+ display drawable for a specific Shoes drawable, and pair it with
    # the linkable ID for this Shoes drawable.
    #
    # @param drawable_class_name [String] The class name of the Shoes drawable, e.g. Shoes::Button
    # @param drawable_id [String] the linkable ID for drawable events
    # @param properties [Hash] a JSON-serialisable Hash with the drawable's display properties
    # @param is_widget [Boolean] whether the class is a user-defined Shoes::Widget subclass
    # @return [Scarpe::GTK::Drawable] the newly-created drawable
    def create_display_drawable_for(drawable_class_name, drawable_id, properties, is_widget:, parent_id:)
      existing = query_display_drawable_for(drawable_id, nil_ok: true)
      if existing
        @log.warn("There is already a display drawable for #{drawable_id.inspect}! Returning #{existing.class.name}.")
        return existing
      end

      if drawable_class_name == "App"
        unless @doc_root
          raise Scarpe::MissingDocRootError, "DocumentRoot is supposed to be created before App!"
        end

        display_app = Scarpe::GTK::App.new(properties)
        display_app.document_root = @doc_root

        set_drawable_pairing(drawable_id, display_app)

        return display_app
      end

      # Nil parent is fine for DocumentRoot and any TextDrawable, so we have to specify nil_ok.
      display_parent = Scarpe::GTK::DisplayService.instance.query_display_drawable_for(parent_id, nil_ok: true)

      # Create a corresponding display drawable
      if is_widget
        display_class = Scarpe::GTK::Flow
      else
        display_class = Scarpe::GTK::Drawable.display_class_for(drawable_class_name)
        unless display_class < Shoes::Linkable
          raise Scarpe::BadDisplayClassType, "Wrong display class type #{display_class.inspect} for class name #{drawable_class_name.inspect}!"
        end
      end
      display_drawable = display_class.new(properties, parent: display_parent)
      set_drawable_pairing(drawable_id, display_drawable)

      if drawable_class_name == "DocumentRoot"
        # DocumentRoot is created before App. Mostly doc_root is just like any other drawable,
        # but we'll want a reference to it when we create App.
        @doc_root = display_drawable
      end

      display_drawable
    end

    # Destroy the display service and the app. Quit the process (eventually.)
    #
    # @return [void]
    def destroy
      #@app.destroy
      DisplayService.instance = nil
    end
  end
end
