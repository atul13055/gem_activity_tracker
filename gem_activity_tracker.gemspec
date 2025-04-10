# frozen_string_literal: true
require_relative "lib/gem_activity_tracker/version"

Gem::Specification.new do |spec|
  spec.name          = "gem_activity_tracker"
  spec.version       = GemActivityTracker::VERSION
  spec.authors       = ["Atul Yadav"]
  spec.email         = ["atulyadav9039@gmail.com"]

  spec.summary       = "Track gem and project activity in Ruby/Rails projects"
  spec.description   = "A CLI gem to analyze Ruby/Rails projects and track activity: models, migrations, routes, Git, schema, and more."
  spec.homepage      = "https://github.com/atul13055/gem_activity_tracker"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "exe/*", "README.md", "LICENSE.txt", "*.gemspec"]
  spec.bindir        = "exe"
  spec.executables   = ["gem_activity_tracker"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.1.0"

  spec.add_dependency "listen", "~> 3.0"
end
