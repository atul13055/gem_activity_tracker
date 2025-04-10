# lib/gem_activity_tracker.rb

require_relative "gem_activity_tracker/version"
require_relative "gem_activity_tracker/tracker"
require_relative "gem_activity_tracker/watcher"
require_relative "gem_activity_tracker/railtie" if defined?(Rails)

module GemActivityTracker
  class Error < StandardError; end
end
