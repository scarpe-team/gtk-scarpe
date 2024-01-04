# frozen_string_literal: true

require "minitest"
require "scarpe/components/string_helpers"

# Test framework code to allow Scarpe to execute Shoes-Spec test code.

class Scarpe::GTK::Test
  def self.run_shoes_spec_test_code(code, class_name: nil, test_name: nil)
    if @shoes_spec_init
      raise Shoes::Errors::MultipleShoesSpecRunsError, "Scarpe-Webview can only run a single Shoes spec per process!"
    end

    @shoes_spec_init = true

    require "scarpe/components/minitest_export_reporter"
    Minitest::Reporters::ShoesExportReporter.activate!

    class_name ||= ENV["SHOES_MINITEST_CLASS_NAME"] || "TestShoesSpecCode"
    test_name ||= ENV["SHOES_MINITEST_METHOD_NAME"] || "test_shoes_spec"

    test_class = Class.new(Scarpe::GTK::ShoesSpecTest)
    Object.const_set(Scarpe::Components::StringHelpers.camelize(class_name), test_class)
    test_name = "test_" + test_name unless test_name.start_with?("test_")
    test_class.define_method(test_name) do
      eval(code)
    end

    Scarpe::GTK::App.instance.on_post_init do
      Minitest.run []

      Shoes::App.instance.destroy
    end
  end
end

class Scarpe::GTK::ShoesSpecProxy
  attr_reader :obj
  attr_reader :linkable_id
  attr_reader :display

  SHOES_EVENTS = [:click, :hover, :leave, :change]

  def initialize(obj)
    @obj = obj
    @linkable_id = obj.linkable_id
    @display = ::Shoes::DisplayService.display_service.query_display_drawable_for(obj.linkable_id)

    unless @display
      raise "Can't find display widget for #{obj.inspect}!"
    end
  end

  def method_missing(method, ...)
    if @obj.respond_to?(method)
      self.singleton_class.define_method(method) do |*args, **kwargs, &block|
        @obj.send(method, *args, **kwargs, &block)
      end
      send(method, ...)
    else
      super # raise an exception
    end
  end

  def trigger(event_name, *args)
    raise "Implement me!"
  end

  SHOES_EVENTS.each do |ev|
    define_method "trigger_#{ev}" do |*args|
      trigger(ev, *args)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @obj.respond_to_missing?(method_name, include_private)
  end
end

# When running ShoesSpec tests, we create a parent class for all of them
# with the appropriate convenience methods and accessors.
class Scarpe::GTK::ShoesSpecTest < Minitest::Test
  Shoes::Drawable.drawable_classes.each do |drawable_class|
    finder_name = drawable_class.dsl_name

    define_method(finder_name) do |*args|
      app = Shoes::App.instance

      drawables = app.find_drawables_by(drawable_class, *args)
      raise Shoes::Errors::MultipleDrawablesFoundError, "Found more than one #{finder_name} matching #{args.inspect}!" if drawables.size > 1
      raise Shoes::Errors::NoDrawablesFoundError, "Found no #{finder_name} matching #{args.inspect}!" if drawables.empty?

      Scarpe::GTK::ShoesSpecProxy.new(drawables[0])
    end
  end

  def drawable(*specs)
    drawables = app.find_drawables_by(*specs)
    raise Scarpe::MultipleDrawablesFoundError, "Found more than one #{finder_name} matching #{args.inspect}!" if drawables.size > 1
    raise Scarpe::NoDrawablesFoundError, "Found no #{finder_name} matching #{args.inspect}!" if drawables.empty?

    Scarpe::ShoesSpecProxy.new(drawables[0])
  end

  # We'll also want some kind of timeout and immediate-exit options
end
