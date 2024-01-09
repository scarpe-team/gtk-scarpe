# frozen_string_literal: true

require "test_helper"

require "scarpe/gtk-scarpe/positioning"

# This is a test Drawable, about as simple as possible, to test Positioning
class TestPosDrawable
  include Scarpe::Positioning

  def initialize(d_type, props, children: [], native_size: nil)
    @props = props
    @children = children
    @native_size = native_size

    position_as(d_type)
  end

  def pos_properties
    @props
  end

  def pos_children
    @children
  end

  def pos_minimum_size
    @native_size || [0, 0]
  end
end

class TestPositioningModule < Minitest::Test
  # Methods for creating test drawables
  def doc_root(props = {}, children: [])
    default = { "width" => 600, "height" => 300 }
    TestPosDrawable.new("DocumentRoot", default.merge(props), children:)
  end

  def drawable(native_w, native_h, props: {})
    TestPosDrawable.new("Drawable", props, native_size: [native_w, native_h])
  end

  ### Actual Tests

  def test_simple_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root app_size
    pos = top_flow.calculate_layout(app_size)

    assert_equal({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_percent_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root({ "width" => "100%", "height" => "100%" })
    pos = top_flow.calculate_layout(app_size)

    assert_equal({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_float_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root({"width" => 1.0, "height" => 1.0})
    pos = top_flow.calculate_layout(app_size)

    assert_equal({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_simple_int_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    # This is like a 100x50 button inside a Shoes.app
    top_flow = doc_root(app_size, children: [drawable(100, 50)])
    pos = top_flow.calculate_layout(app_size)

    assert_equal([{ "top" => 0, "left" => 0, "width" => 100, "height" => 50 }], pos["children"])
  end
end
