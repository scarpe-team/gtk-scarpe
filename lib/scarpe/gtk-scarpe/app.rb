# frozen_string_literal: true

module Scarpe::GTK
  class App < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    attr_writer :shoes_linkable_id
    attr_writer :document_root

    attr_reader :canvas

    def initialize(properties)
      super(properties, parent: nil)

      @canvas = Gtk::Fixed.new

      bind_shoes_event(event_name: "init") { init }
      bind_shoes_event(event_name: "run") { run }
      bind_shoes_event(event_name: "destroy") { destroy }

      bind_shoes_event(event_name: "builtin") do |cmd_name, args|
        case cmd_name
        when "font"
          raise "Implement me!"
        when "alert"
          raise "Implement me!"
        else
          raise Scarpe::UnknownBuiltinCommandError, "Unexpected builtin command: #{cmd_name.inspect}!"
        end
      end
    end

    def init
    end

    def run
      @gtk_app = Gtk::Application.new("org.gtk.example", :flags_none)

      @gtk_app.signal_connect "startup" do |app|
        STDERR.puts "STARTUP"
        # Load CSS
        provider = Gtk::CssProvider.new
        provider.load data: "GtkWindow { background-color: white; }" # CSS data here
        Gtk::StyleContext.add_provider_for_display(Gdk::Display.default, provider, :application)
      end

      @gtk_app.signal_connect "activate" do |app|
        STDERR.puts "ACTIVATE"
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
        put_to_canvas
        @main_window.show
      end

      @gtk_app.run
    end

    def destroy
    end

    def put_to_canvas
      ctx = {
        top: 0,
        left: 0,
        rotate: 0,
      }
      @canvas.children.each { |child| @canvas.remove child }
      @document_root.put_to_canvas(@canvas, ctx)
    end
  end
end
