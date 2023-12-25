# frozen_string_literal: true

require_relative "lib/scarpe/gtk-scarpe/version"

Gem::Specification.new do |spec|
  spec.name = "gtk-scarpe"
  spec.version = Scarpe::GTK::VERSION
  spec.authors = ["Noah Gibbs"]
  spec.email = ["the.codefolio.guy@gmail.com"]

  spec.summary = "A GTK+ implementation of the Scarpe (Shoes) Ruby GUI library"
  spec.description = "Shoes is a GUI DSL standard for writing desktop windowed apps in Ruby. Scarpe implements it. gtk-scarpe is a GTK+ display service for Scarpe."
  spec.homepage = "http://github.com/scarpe-team/gtk-scarpe"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  #spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "scarpe-components", "0.3.0"
  spec.add_dependency "lacci", "0.3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
