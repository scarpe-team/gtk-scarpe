# frozen_string_literal: true

module Scarpe::GTK
  class App < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    attr_writer :shoes_linkable_id
    attr_writer :document_root

    attr_reader :canvas

    class << self
      attr_accessor :instance
    end

    def initialize(properties)
      if Scarpe::GTK::App.instance
        raise Scarpe::MultipleAppObjectsError, "Only one Scarpe::GTK::App is allowed at once!"
      end
      Scarpe::GTK::App.instance = self

      super(properties, parent: nil)

      @canvas = Gtk::Fixed.new
      @post_init_methods = []
      @alerts = []

      bind_shoes_event(event_name: "init") { init }
      bind_shoes_event(event_name: "run") { run }
      bind_shoes_event(event_name: "destroy") { destroy }

      bind_shoes_event(event_name: "builtin") do |cmd_name, args|
        case cmd_name
        when "font"
          raise "Implement me!"
        when "alert"
          # TODO: we should add a parent window where possible.
          dialog = Gtk::MessageDialog.new message: args[0], type: :error, parent: nil, flags: nil, buttons: :ok
          dialog.signal_connect(:response) do
            dialog.destroy
            @alerts.delete(dialog)
          end
          dialog.show
          @alerts << dialog
        else
          raise Scarpe::UnknownBuiltinCommandError, "Unexpected builtin command: #{cmd_name.inspect}!"
        end
      end
    end

    def init
    end

    def on_post_init(&block)
      @post_init_methods << block
    end

    def run
      @gtk_app = Gtk::Application.new("org.gtk.example", :flags_none)

      @gtk_app.signal_connect "startup" do |app|
        # Load CSS
        provider = Gtk::CssProvider.new
        provider.load data: "GtkWindow { background-color: white; }" # CSS data here
        Gtk::StyleContext.add_provider_for_display(Gdk::Display.default, provider, :application)
      end

      @gtk_app.signal_connect "activate" do |app|
        @main_window = Gtk::ApplicationWindow.new(app)
        #@main_window.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
        @main_window.title = @title
        @main_window.set_default_size @width, @height

        if @fullscreen # Does Lacci do fullscreen yet?
          @main_window.decorated = false
          @main_window.maximize
        elsif @maximize # or maximize?
          @main_window.maximize
        end

        @main_window.child = @canvas
        full_calculate_and_draw
        @main_window.show

        @post_init_methods.each(&:call)
      end

      @gtk_app.run
    end

    def destroy
      @gtk_app.quit
    end

    # Let all drawables figure out their size and placement
    def full_calculate_and_draw
      calc_context = {
        "width" => @width,
        "height" => @height,
        "left" => 0,
        "top" => 0,
      }
      layout = @document_root.calculate_layout(calc_context)

      @canvas.children.each { |child| @canvas.remove child }
      @document_root.put_to_canvas(@canvas, layout)
    end
  end
end
