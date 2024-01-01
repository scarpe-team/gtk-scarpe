# frozen_string_literal: true

require "test_helper"

# Having trouble here - need to make sure we're getting
# assertions and exceptions as expected.
class TestSSpecInfrastructure < GtkSpecTest
  self.logger_dir = File.expand_path("#{__dir__}/../logger")

  def test_simple_assertion_success
    run_gtk_sspec_code(<<~'SSPEC')
      ---
      ----------- app code
      Shoes.app do
      end
      ----------- test code
      assert_equal true, true
    SSPEC
  end

  def test_exception
    run_gtk_sspec_code(<<~'SSPEC', expect_result: :error)
      ---
      ----------- app code
      Shoes.app do
      end
      ----------- test code
      raise "Yup, that's an exception!"
    SSPEC
  end

  def test_app_exception
    run_gtk_sspec_code(<<~'SSPEC', expect_result: :no_file, process_success: false)
      ---
      ----------- app code
      Shoes.app do
        raise "Yup, that's an exception!"
      end
      ----------- test code
      assert_equal true, true
    SSPEC
  end

  def test_many_assertions
    run_gtk_sspec_code(<<~'SSPEC', expect_assertions_min: 10)
      ---
      ----------- app code
      Shoes.app do
      end
      ----------- test code
      10.times { assert_equal true, true }
    SSPEC
  end

  def test_skip
    run_gtk_sspec_code(<<~'SSPEC', expect_result: :skip)
      ---
      ----------- app code
      Shoes.app do
      end
      ----------- test code
      skip
    SSPEC
  end

  def test_assertion_fail
    run_gtk_sspec_code(<<~'SSPEC', expect_result: :fail)
      ---
      ----------- app code
      Shoes.app do
      end
      ----------- test code
      assert_equal true, false, "This should always fail!"
    SSPEC
  end
end
