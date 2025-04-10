require 'rails/railtie'

module GemActivityTracker
  class Railtie < Rails::Railtie
    initializer "gem_activity_tracker.auto_track" do
      Rails.application.config.after_initialize do
        # Delay the execution slightly to avoid blocking boot
        Thread.new do
          sleep(3) # Give Rails a moment to fully start

          begin
            path = Rails.root.to_s
            report_path = File.join(path, "activity_tracker", "report.yml")
            tracking_enabled = ENV.fetch('GEM_ACTIVITY_TRACKER_ENABLED', 'true') == 'true'

            if tracking_enabled
              Rails.logger.info "[GemActivityTracker] 🔍 Checking for project changes..."
              
              last_data = File.exist?(report_path) ? YAML.load_file(report_path) : {}
              
              current_data = GemActivityTracker::Tracker.collect_data(path)

              if last_data != current_data
                Rails.logger.info "[GemActivityTracker] 🔄 Project activity changed. Updating report..."
                GemActivityTracker::Tracker.track(path)
              else
                Rails.logger.info "[GemActivityTracker] ✅ No project changes detected."
              end

              Rails.logger.info "[GemActivityTracker] 👀 Starting auto-watcher for #{path}..."
              GemActivityTracker::Watcher.start(path)
            else
              Rails.logger.info "[GemActivityTracker] ⚙️ Auto-tracking disabled via ENV."
            end
          rescue => e
            Rails.logger.error "[GemActivityTracker] ⚠️ Error: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
          end
        end
      end
    end
  end
end
