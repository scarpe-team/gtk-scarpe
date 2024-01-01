# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "scarpe/gtk-scarpe"

require "scarpe/components/file_helpers"
require "scarpe/components/unit_test_helpers"
require "scarpe/components/minitest_result"

require "minitest/autorun"

class GtkSpecTest < Minitest::Test
  include Scarpe::Test::LoggedTest
  include Scarpe::Components::FileHelpers

  SCARPE_EXE = File.expand_path("../exe/gtk-scarpe", __dir__)

  def run_gtk_sspec_code(sspec_code, **kwargs)
    with_tempfile(["scarpe_sspec_test_#{self.class.name}_#{self.name}", ".sspec"], sspec_code) do |filename|
      run_gtk_sspec(filename, **kwargs)
    end
  end

  def run_gtk_sspec(
    filename,
    process_success: true,
    expect_assertions_min: nil,
    expect_assertions_max: nil,
    expect_result: :success,
    display_service: "gtk-scarpe"
  )
    test_output = File.expand_path(File.join __dir__, "sspec.json")
    File.unlink(test_output) if File.exist?(test_output)
    test_method_name = self.name
    test_class_name = self.class.name

    with_tempfile("scarpe_log_config.json", JSON.dump(log_config_for_test)) do |scarpe_log_config|
      # Start the application using the exe/scarpe utility
      # For unit testing always supply --debug so we get the most logging
      cmd = \
        "SCARPE_DISPLAY_SERVICE=#{display_service} " +
        "SCARPE_LOG_CONFIG=\"#{scarpe_log_config}\" " +
        "SHOES_MINITEST_EXPORT_FILE=\"#{test_output}\" " +
        "SHOES_MINITEST_CLASS_NAME=\"#{test_class_name}\" " +
        "SHOES_MINITEST_METHOD_NAME=\"#{test_method_name}\" " +
        "LOCALAPPDATA=\"#{Dir.tmpdir}\"" +
        "ruby #{SCARPE_EXE} --debug --dev #{filename}"
      process_result = system(cmd)

      if process_result != process_success
        if process_success
          assert false, "Expected sspec test process to return success and it failed! Exit code: #{$?.exitstatus}"
        else
          assert false, "Expected sspec test process to return failure and it succeeded!"
        end
      end
    end

    if expect_result == :no_file
      assert !File.exist?(test_output), "Expected no output file, but instead found file #{test_output.inspect}!"
      return
    end

    result = Scarpe::Components::MinitestResult.new(test_output)
    correct, msg = result.check(expect_result:, min_asserts: expect_assertions_min, max_asserts: expect_assertions_max)

    if correct
      assert_equal true, true # Yup, worked fine
    else
      assert false, "Minitest result: #{msg}"
    end
  end
end
