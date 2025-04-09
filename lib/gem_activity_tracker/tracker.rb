require 'yaml'
require 'json'
require 'fileutils'
require 'psych'
require 'csv'
require 'digest'

module GemActivityTracker
  class Tracker
    def self.track(path)
      puts "🔍 Tracking project at: #{path}"
      data = collect_data(path)

      FileUtils.mkdir_p("#{path}/activity_tracker")
      File.write("#{path}/activity_tracker/report.yml", data.to_yaml)

      puts "✅ Report generated at: #{path}/activity_tracker/report.yml"
    end

    def self.collect_data(path)
      {
        ruby_version: `ruby -v`.strip,
        rails_version: get_rails_version(path),
        database: detect_database(path),
        models: list_and_count_files(path, "app/models"),
        controllers: list_and_count_files(path, "app/controllers"),
        jobs: list_and_count_files(path, "app/jobs"),
        mailers: list_and_count_files(path, "app/mailers"),
        services: list_and_count_files(path, "app/services"),
        migrations: migration_changes(path),
        schema_hash: schema_hash(path),
        routes: get_routes(path),
        git_log: get_git_log(path)
      }
    end

    def self.report
      file = "activity_tracker/report.yml"
      if File.exist?(file)
        puts YAML.load_file(file).to_yaml
      else
        puts "❌ No report found. Please run tracking first."
      end
    end

    def self.list_and_count_files(base, dir)
      path = File.join(base, dir)
      files = Dir.glob("#{path}/**/*.rb").map { |f| f.gsub(base + '/', '') }
      {
        count: files.count,
        files: files
      }
    end

    def self.get_rails_version(path)
      gemfile = File.join(path, 'Gemfile.lock')
      return 'Not a Rails project' unless File.exist?(gemfile)

      File.read(gemfile)[/rails \((.*?)\)/, 1]
    end

    def self.detect_database(path)
      db_file = File.join(path, "config/database.yml")
      return 'Unknown' unless File.exist?(db_file)

      config = YAML.load_file(db_file, aliases: true)
      config["development"]["adapter"] rescue "Unknown"
    end

    def self.get_routes(path)
      output = `cd #{path} && RAILS_ENV=development bundle exec rails routes 2>/dev/null`
      output.empty? ? "No routes found or Rails not installed" : output
    end

    def self.migration_changes(path)
      files = Dir.glob("#{path}/db/migrate/*.rb")
      recent = files.sort_by { |f| File.mtime(f) }.last(10)
      {
        count: files.count,
        recent_changes: recent.map { |f| File.basename(f, ".rb").gsub(/^\d+_/, '') }
      }
    end

    def self.schema_hash(path)
      file = File.join(path, "db/schema.rb")
      return nil unless File.exist?(file)
      Digest::MD5.hexdigest(File.read(file))
    end

    def self.get_git_log(path)
      Dir.chdir(path) do
        log = `git log --pretty=format:'%h - %an (%ad): %s' --date=short -n 20`
        log.split("\n")
      end
    end

    def self.export(path, format = :json)
      file = "#{path}/activity_tracker/report.yml"
      return puts "❌ Report not found." unless File.exist?(file)

      data = YAML.load_file(file)

      case format
      when :json
        File.write("#{path}/activity_tracker/report.json", JSON.pretty_generate(data))
        puts "✅ Exported to report.json"
      when :csv
        CSV.open("#{path}/activity_tracker/report.csv", "w") do |csv|
          csv << ["Key", "Value"]
          data.each do |key, value|
            if value.is_a?(Hash)
              csv << [key.to_s, ""]
              value.each { |k, v| csv << ["  #{k}", v] }
            elsif value.is_a?(Array)
              csv << [key.to_s, "#{value.count} items"]
              value.each { |item| csv << ["", item] }
            else
              csv << [key.to_s, value]
            end
          end
        end
        puts "✅ Exported to report.csv"
      else
        puts "❌ Unsupported format: #{format}"
      end
    end
  end
end
