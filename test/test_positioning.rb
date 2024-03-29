# frozen_string_literal: true

require "test_helper"

# This is a test Drawable, about as simple as possible, to test Positioning
class TestPosDrawable
  include Scarpe::Positioning

  def initialize(d_type, props, children: [], native_size: nil)
    @props = props
    @children = children
    @native_size = native_size

    if @props.any? { |k, _v| k.is_a?(Symbol) }
      raise("BAD TEST DATA: #{@props.inspect}")
    end

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

  def flow(props = {}, children: [])
    TestPosDrawable.new("Flow", props, children:)
  end

  def drawable(native_w, native_h, props: {})
    TestPosDrawable.new("Drawable", props, native_size: [native_w, native_h])
  end

  ### Actual Tests

  def test_simple_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root app_size
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_percent_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root({ "width" => "100%", "height" => "100%" })
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_float_doc_root
    app_size = { "width" => 300, "height" => 450 }
    top_flow = doc_root({"width" => 1.0, "height" => 1.0})
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 300, "height" => 450, "children" => [] }, pos)
  end

  def test_simple_native_size_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    # This is like a 100x50 button inside a Shoes.app
    top_flow = doc_root(app_size, children: [drawable(100, 50)])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 100, "height" => 50 }, pos["children"][0])
  end

  def test_simple_int_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    # This is like a 100x50 button inside a Shoes.app
    top_flow = doc_root(app_size, children: [drawable(100, 50, props: { "width" => 110 })])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 110, "height" => 50 }, pos["children"][0])
  end

  def test_simple_pct_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(10, 30, props: { "width" => "10%", "height" => "10%" })])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 30, "height" => 45 }, pos["children"][0])
  end

  def test_simple_float_width_drawable_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(20, 50, props: { "width" => 0.2, "height" => 0.2 })])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 0, "width" => 60, "height" => 90 }, pos["children"][0])
  end

  def test_simple_drawable_in_stack
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

  def test_simple_neg_float_width_drawable_in_slot
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      stack({ "width" => 100, "height" => "100%" }, children: [
        drawable(75, 50, props: { "width" => -0.2 })
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # Drawable should be 80 wide (100 * 0.8)
    assert_equal 80, pos["children"][0]["children"][0]["width"]
  end

  def test_simple_neg_percent_width_drawable_in_slot
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      stack({ "width" => 100, "height" => "100%" }, children: [
        drawable(75, 50, props: { "width" => "-20%" })
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # Drawable should be 80 wide (100 * 0.8)
    assert_equal 80, pos["children"][0]["children"][0]["width"]
  end

  def test_simple_drawable_with_left_specified_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(10, 30, props: { "left" => 30, "width" => "10%", "height" => "10%" })])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 30, "width" => 30, "height" => 45 }, pos["children"][0])
  end

  def test_simple_drawable_with_left_pct_specified_in_doc_root
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [drawable(10, 30, props: { "left" => "10%", "width" => "10%", "height" => "10%" })])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "top" => 0, "left" => 30, "width" => 30, "height" => 45 }, pos["children"][0])
  end

  def test_two_drawables_in_stack
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      stack({ "width" => "100%", "height" => "100%" }, children: [
        drawable(75, 50, props: {}),
        drawable(100, 65, props: {}),
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # First drawable should be 75 wide, 50 tall and at 0,0
    assert_has_properties({ "width" => 75, "height" => 50, "top" => 0, "left" => 0 }, pos["children"][0]["children"][0])
    # Second drawable should be 100 wide, 65 tall and at 0, 50 (just after first drawable)
    assert_has_properties({ "width" => 100, "height" => 65, "top" => 50, "left" => 0 }, pos["children"][0]["children"][1])
  end

  def test_two_drawables_in_flow
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      flow({ "width" => "100%", "height" => "100%" }, children: [
        drawable(75, 50, props: {}),
        drawable(100, 65, props: {}),
      ])
    ])
    pos = top_flow.calculate_layout(app_size)

    # First drawable should be 75 wide, 50 tall and at 0,0
    assert_has_properties({ "width" => 75, "height" => 50, "top" => 0, "left" => 0 }, pos["children"][0]["children"][0])
    # Second drawable should be 100 wide, 65 tall and at 0, 50 (just after first drawable)
    assert_has_properties({ "width" => 100, "height" => 65, "top" => 0, "left" => 75 }, pos["children"][0]["children"][1])
  end

  def test_flow_wrapping_drawables
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      # First row
      drawable(100, 50),
      drawable(150, 75),

      # Second row
      drawable(100, 90),
      drawable(175, 50),
    ])
    pos = top_flow.calculate_layout(app_size)

    # First row
    assert_has_properties({ "width" => 100, "height" => 50, "top" => 0, "left" => 0 }, pos["children"][0])
    assert_has_properties({ "width" => 150, "height" => 75, "top" => 0, "left" => 100 }, pos["children"][1])
    # Second row
    assert_has_properties({ "width" => 100, "height" => 90, "top" => 75, "left" => 0 }, pos["children"][2])
    assert_has_properties({ "width" => 175, "height" => 50, "top" => 75, "left" => 100 }, pos["children"][3])
  end

  def test_flow_wrapping_drawables_with_shorter_second_row_and_very_wide_third_row
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [
      # First row
      drawable(100, 50),
      drawable(150, 90),

      # Second row
      drawable(100, 40),
      drawable(175, 50),

      # Third row
      drawable(350, 50),

      # Fourth row
      drawable(250, 50),
    ])
    pos = top_flow.calculate_layout(app_size)

    # First row
    assert_has_properties({ "width" => 100, "height" => 50, "top" => 0, "left" => 0 }, pos["children"][0])
    assert_has_properties({ "width" => 150, "height" => 90, "top" => 0, "left" => 100 }, pos["children"][1])
    # Second row
    assert_has_properties({ "width" => 100, "height" => 40, "top" => 90, "left" => 0 }, pos["children"][2])
    assert_has_properties({ "width" => 175, "height" => 50, "top" => 90, "left" => 100 }, pos["children"][3])
    # Third row
    assert_has_properties({ "width" => 350, "height" => 50, "top" => 140, "left" => 0 }, pos["children"][4])
    # Fourth row
    assert_has_properties({ "width" => 250, "height" => 50, "top" => 190, "left" => 0 }, pos["children"][5])
  end

  def test_expanding_stack_from_inside
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [stack(children: [
      drawable(100, 50),
      drawable(150, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "width" => 150, "height" => 140 }, pos["children"][0])
  end

  def test_expanding_flow_from_inside
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children: [flow(children: [
      drawable(100, 50),
      drawable(150, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "width" => 250, "height" => 90 }, pos["children"][0])
  end

  def test_stack_with_left_property
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children:[stack({ "left" => "10%" }, children: [
      drawable(200, 100, props: { "top" => 30 }),
      drawable(150, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "left" => 30.0, "width" => 150, "height" => 90 }, pos["children"][0])
    assert_has_properties({ "width" => 200, "height" => 100, "top" => 30, "left" => 0 }, pos["children"][0]["children"][0])
    assert_has_properties({ "width" => 150, "height" => 90, "top" => 0, "left" => 0 }, pos["children"][0]["children"][1])
  end

  def test_stack_with_absolutely_positioned_element_inside
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children:[stack(children: [
      drawable(200, 100, props: { "top" => 30 }),
      drawable(150, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "width" => 150, "height" => 90 }, pos["children"][0])
    assert_has_properties({ "width" => 200, "height" => 100, "top" => 30, "left" => 0 }, pos["children"][0]["children"][0])
    assert_has_properties({ "width" => 150, "height" => 90, "top" => 0, "left" => 0 }, pos["children"][0]["children"][1])
  end

  def test_flow_with_absolutely_positioned_element_inside
    app_size = { "width" => 300, "height" => 450 }

    top_flow = doc_root(app_size, children:[flow(children: [
      drawable(200, 100, props: { "top" => 30 }),
      drawable(150, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "width" => 150, "height" => 90 }, pos["children"][0])
    assert_has_properties({ "width" => 200, "height" => 100, "top" => 30, "left" => 0 }, pos["children"][0]["children"][0])
    assert_has_properties({ "width" => 150, "height" => 90, "top" => 0, "left" => 0 }, pos["children"][0]["children"][1])
  end

  def test_narrower_stack_positioning
    app_size = { "width" => 300, "height" => 450 }

    # Test a stack with left coord 30, width 150
    top_flow = doc_root(app_size, children:[stack({ "left" => "10%", "width" => "50%" }, children: [
      drawable(100, 100),
      drawable(125, 90),
    ])])
    pos = top_flow.calculate_layout(app_size)

    assert_has_properties({ "left" => 30, "width" => 150, "height" => 190 }, pos["children"][0])
    assert_has_properties({ "width" => 100, "height" => 100, "top" => 0, "left" => 0 }, pos["children"][0]["children"][0])
    assert_has_properties({ "width" => 125, "height" => 90, "top" => 100, "left" => 0 }, pos["children"][0]["children"][1])
  end

  # TODO: make sure flows wrap properly even if they're smaller than the slot width (e.g. 30%)
  # TODO: margins
end
