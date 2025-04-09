require 'listen'
require 'fileutils'

module GemActivityTracker
  class Watcher
    def self.start(path)
      puts "👀 Watching for changes in: #{path}"

      listener = Listen.to(path, ignore: [%r{activity_tracker/}, %r{tmp/}, %r{log/}, /\.log$/]) do |modified, added, removed|
        changes = { modified: modified, added: added, removed: removed }
        log_file = File.join(path, "activity_tracker", "log.txt")
        FileUtils.mkdir_p(File.dirname(log_file))

        any_change = false

        changes.each do |type, files|
          next if files.empty?

          files.each do |file|
            timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
            relative_path = file.sub("#{path}/", '')
            log_line = "[#{timestamp}] #{type.to_s.capitalize}: #{relative_path}"
            puts log_line
            File.open(log_file, "a") { |f| f.puts log_line }
            any_change = true
          end
        end

        if any_change
          puts "🔄 Updating activity report..."
          GemActivityTracker::Tracker.track(path)
        end
      end

      listener.start
      puts "✅ Watcher started. Press Ctrl+C to stop."
      sleep
    end
  end
end
