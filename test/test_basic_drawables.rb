# frozen_string_literal: true

require "test_helper"

# Having trouble here - need to make sure we're getting
# assertions and exceptions as expected.
class TestBasicDrawables < GtkSpecTest
  self.logger_dir = File.expand_path("#{__dir__}/../logger")

  def test_para_and_text_drawables_dont_crash
    run_gtk_sspec_code(<<~'SSPEC')
      ---
      ----------- app code
      Shoes.app do
        para "Hello world"
        button "OK"
      end
      ----------- test code
      assert_equal "Hello world", para.text
      assert_equal "OK", button.text
    SSPEC
  end
end
