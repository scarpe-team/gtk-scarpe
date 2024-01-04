# frozen_string_literal: true

require "test_helper"

# Having trouble here - need to make sure we're getting
# assertions and exceptions as expected.
class TestBasicDrawables < GtkSpecTest
  self.logger_dir = File.expand_path("#{__dir__}/../logger")

  def test_para_and_text_drawables_drawables_dont_crash
    run_gtk_sspec_code(<<~'SSPEC', expect_assertions_min: 2)
      ---
      ----------- app code
      Shoes.app do
        para "Hello world", em(" from"), strong(" Shoes"), sub(" with"), sup(" love"), del(" and"), ins(" adoration"), code(", yo!")
        button "OK"
      end
      ----------- test code
      assert_equal "Hello world from Shoes with love and adoration, yo!", para.text
      assert_equal "OK", button.text
    SSPEC
  end

  def test_button_click_and_para_replace
    run_gtk_sspec_code(<<~'SSPEC')
      ---
      ----------- app code
      Shoes.app do
        p = para "Hello world"
        button("OK") do
          p.replace("Clickity!")
        end
      end
      ----------- test code
      button.trigger_click
      assert_equal "Clickity!", para.text
    SSPEC
  end
end
