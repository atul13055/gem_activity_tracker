require 'rails/railtie'

module GemActivityTracker
  class Railtie < Rails::Railtie
    initializer "gem_activity_tracker.auto_track" do
      ActiveSupport.on_load(:after_initialize) do
        Thread.new do
          begin
            path = Rails.root.to_s
            report_path = File.join(path, "activity_tracker", "report.yml")

            last_data = File.exist?(report_path) ? YAML.load_file(report_path) : {}
            current_data = GemActivityTracker::Tracker.collect_data(path)

            if last_data != current_data
              puts "🔄 Project activity changed. Updating report..."
              GemActivityTracker::Tracker.track(path)
            else
              puts "✅ No project changes detected."
            end

            # ✅ Start auto watching
            puts "👀 Starting auto-watcher for #{path} from Railtie..."
            GemActivityTracker::Watcher.start(path)
          rescue => e
            puts "⚠️ GemActivityTracker error: #{e.message}"
          end
        end
      end
    end
  end
end
