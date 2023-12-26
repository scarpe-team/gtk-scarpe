# frozen_string_literal: true

module Scarpe::GTK
  class App < Drawable # App inherits from Drawable to set up linkable IDs and event methods
    attr_writer :shoes_linkable_id
    attr_writer :document_root

    def initialize(properties)
      super

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
    end

    def destroy
    end
  end
end
