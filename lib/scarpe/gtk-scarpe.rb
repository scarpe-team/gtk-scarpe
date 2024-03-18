# frozen_string_literal: true

ENV['SCARPE_DISPLAY_SERVICE'] = "gtk-scarpe"

require_relative "gtk-scarpe/version"

require "shoes"
require "lacci/scarpe_core"

require "gtk4"
require "gdk4"

module GLib
  module_function
  def exit_application(exception, status)
    raise exception if exception.class.name == "SystemExit"
    super(exception, status)
  end
end

require "scarpe/components/errors"
require "scarpe/components/modular_logger"
# Set up hierarchical logging using the SCARPE_LOG_CONFIG var for configuration
log_config = if ENV["SCARPE_LOG_CONFIG"]
  JSON.load_file(ENV["SCARPE_LOG_CONFIG"])
else
  ENV["SCARPE_DEBUG"] ? Shoes::Log::DEFAULT_DEBUG_LOG_CONFIG : Shoes::Log::DEFAULT_LOG_CONFIG
end
Shoes::Log.instance = Scarpe::Components::ModularLogImpl.new
Shoes::Log.configure_logger(log_config)

require "scarpe/components/segmented_file_loader"
loader = Scarpe::Components::SegmentedFileLoader.new
Shoes.add_file_loader loader

# What actual fonts are available by default in GTK+?
Shoes::FONTS.push("Helvetica", "Arial")

#Shoes::FEATURES.push(:gtk)
#Shoes::EXTENSIONS.push(:scarpe)

require_relative "gtk-scarpe/shoes_spec"
Shoes::Spec.instance = Scarpe::GTK::Test

require_relative "gtk-scarpe/display_service"
Shoes::DisplayService.set_display_service_class(Scarpe::GTK::DisplayService)

require_relative "errors"

require_relative "gtk-scarpe/positioning"
require_relative "gtk-scarpe/drawable"
require_relative "gtk-scarpe/slot"
require_relative "gtk-scarpe/app"

require_relative "gtk-scarpe/text_drawable"
require_relative "gtk-scarpe/para"
require_relative "gtk-scarpe/button"
require_relative "gtk-scarpe/check"
require_relative "gtk-scarpe/radio"

#require_relative "gtk-scarpe/art_drawables"
#require_relative "gtk-scarpe/subscription_item"
#require_relative "gtk-scarpe/progress"
#require_relative "gtk-scarpe/image"
#require_relative "gtk-scarpe/edit_box"
#require_relative "gtk-scarpe/edit_line"
#require_relative "gtk-scarpe/list_box"
#require_relative "gtk-scarpe/shape"
#require_relative "gtk-scarpe/video"
