# frozen_string_literal: true

require "test_helper"

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

  def stack(props = {}, children: [])
    TestPosDrawable.new("Stack", props, children:)
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

  def test_simple_native_size_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    # This is like a 100x50 button inside a Shoes.app
    top_flow = doc_root(app_size, children: [drawable(100, 50)])
    pos = top_flow.calculate_layout(app_size)

    assert_equal([{ "top" => 0, "left" => 0, "width" => 100, "height" => 50 }], pos["children"])
  end

  def test_simple_int_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    # This is like a 100x50 button inside a Shoes.app
    top_flow = doc_root(app_size, children: [drawable(100, 50, props: { "width" => 110 })])
    pos = top_flow.calculate_layout(app_size)

    assert_equal([{ "top" => 0, "left" => 0, "width" => 110, "height" => 50 }], pos["children"])
  end

  def test_simple_pct_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(10, 30, props: { "width" => "10%", "height" => "10%" })])
    pos = top_flow.calculate_layout(app_size)

    assert_equal([{ "top" => 0, "left" => 0, "width" => 30, "height" => 45 }], pos["children"])
  end

  def test_simple_float_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(20, 50, props: { "width" => 0.2, "height" => 0.2 })])
    pos = top_flow.calculate_layout(app_size)

    assert_equal([{ "top" => 0, "left" => 0, "width" => 60, "height" => 90 }], pos["children"])
  end

  def test_simple_drawable_in_slot
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      stack({ "width" => 100, "height" => "100%" }, children: [
        drawable(75, 50, props: {})
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # Drawable should be 75 wide, 50 tall
    assert_equal 75, pos["children"][0]["children"][0]["width"]
    assert_equal 50, pos["children"][0]["children"][0]["height"]

    # Slot should be 100 wide, 450 tall
    assert_equal 100, pos["children"][0]["width"]
    assert_equal 450, pos["children"][0]["height"]
  end

  def test_simple_neg_int_width_drawable_in_slot
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      stack({ "width" => 100, "height" => "100%" }, children: [
        drawable(75, 50, props: { "width" => -20 })
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # Drawable should be 80 wide (100 - 20)
    assert_equal 80, pos["children"][0]["children"][0]["width"]
  end

  # TODO: negative int-width drawable
  # TODO: negative float-width drawable
  # TODO: margins
end
