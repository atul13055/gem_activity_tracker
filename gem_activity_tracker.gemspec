# frozen_string_literal: true

require_relative "lib/gem_activity_tracker/version"

Gem::Specification.new do |spec|
  spec.name          = "gem_activity_tracker"
  spec.version       = GemActivityTracker::VERSION
  spec.authors       = ["Atul Yadav"]
  spec.email         = ["atulyadav9039@gmail.com"]

  spec.summary       = "Track gem dependencies of any Ruby project"
  spec.description   = "gem_activity_tracker is a CLI tool to track and analyze gems used in any Ruby project using its Gemfile.lock"
  spec.homepage      = "https://example.com/gem_activity_tracker"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://example.com/gem_activity_tracker"
  spec.metadata["changelog_uri"]     = "https://example.com/gem_activity_tracker/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
    spec.executables = ["gem_activity_tracker"]

  spec.require_paths = ["lib"]
  spec.bindir      = "exe"
  spec.add_dependency "listen", "~> 3.0"

end
