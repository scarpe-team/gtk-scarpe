# frozen_string_literal: true

module Scarpe

    module GTK
      class EditBox < Drawable
        def initialize(properties, parent:)
          super
  
          begin
            @gtk_obj = Gtk::TextView.new
            puts "style #{@gtk_obj.style_context}"
            set_properties(properties)
            set_default_text(properties["text"]) unless properties["text"].nil?
          rescue => e
            raise Scarpe::InternalError, "Error initializing EditBox: #{e.message}"
          end
        end
  
        private
  
        def set_properties(properties)
          puts "editable: #{properties["editable"]}"
          begin
            @gtk_obj.set_size_request(properties["width"] || 200, properties["height"] || 100)
  
            # need to update in lacci first. these are coool tho editable property is useful ig
            @gtk_obj.set_wrap_mode(properties["wrap_mode"] || :word)
            @gtk_obj.set_editable(properties["editable"].nil? ? true : properties["editable"])
  
            @gtk_obj.set_cursor_visible(properties["cursor_visible"].nil? ? true : properties["cursor_visible"])
  
            # Separate method because this might confuse in naming padding, margin as GTK uses it differently
            set_padding_properties(properties)
          rescue => e
            raise Scarpe::InvalidOperationError, "Error setting properties: #{e.message}"
          end
        end
  
        def set_padding_properties(properties)
          begin
            # These are technically padding not margin, but in GTK, they use margin naming.
            @gtk_obj.set_left_margin(properties["padding_left"] || 0)
            @gtk_obj.set_right_margin(properties["padding_right"] || 0)
            @gtk_obj.set_top_margin(properties["padding_top"] || 0)
            @gtk_obj.set_bottom_margin(properties["padding_bottom"] || 0)
          rescue => e
            raise Scarpe::InvalidOperationError, "Error setting padding properties: #{e.message}"
          end
        end
  
        def set_default_text(text)
          begin
            buffer = Gtk::TextBuffer.new
            buffer.text = text
            @gtk_obj.set_buffer(buffer)
          rescue => e
            raise Scarpe::InvalidOperationError, "Error setting default text: #{e.message}"
          end
        end
      end
    end
  end
  