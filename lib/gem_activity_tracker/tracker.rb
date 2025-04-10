require 'yaml'
require 'json'
require 'fileutils'
require 'csv'
require 'digest'
require 'erb'
require 'active_support/all'
require 'active_record'
require 'active_support/dependencies'

module GemActivityTracker
  class Tracker
    def self.track(path)
      puts "🔍 Tracking project at: #{path}"

      if !defined?(Rails) || Rails.root.to_s != path
        $LOAD_PATH.unshift(path)
        ENV['RAILS_ENV'] ||= 'development'
        require File.join(path, 'config', 'environment')
      end

      data = collect_data(path)
      FileUtils.mkdir_p("#{path}/activity_tracker")
      File.write("#{path}/activity_tracker/report.yml", data.to_yaml(line_width: -1))
      puts "✅ Report generated at: #{path}/activity_tracker/report.yml"
    end

    def self.safe_yaml_load(file_path)
      content = ERB.new(File.read(file_path)).result
      if YAML.respond_to?(:safe_load)
        begin
          YAML.safe_load(content, permitted_classes: [Symbol], permitted_symbols: [], aliases: true)
        rescue ArgumentError
          YAML.load(content)
        end
      else
        YAML.load(content)
      end
    rescue => e
      puts "❌ YAML Load Error: #{e.message}"
      {}
    end

    def self.collect_data(path)
      {
        project_name: File.basename(path),
        ruby_version: `ruby -v`.strip,
        rails_version: Rails.version,
        database: detect_database(path),
        models: analyze_models(path),
        controllers: list_and_count_files(path, "app/controllers"),
        jobs: list_and_count_files(path, "app/jobs"),
        mailers: list_and_count_files(path, "app/mailers"),
        services: list_and_count_files(path, "app/services"),
        migrations: migration_changes(path),
        schema_hash: schema_hash(path),
        # routes: get_routes(path),
        git_log: get_git_log(path)
      }
    end

    def self.report
      file = "activity_tracker/report.yml"
      puts File.exist?(file) ? safe_yaml_load(file).to_yaml(line_width: -1) : "❌ No report found."
    end

    def self.list_and_count_files(base, dir)
      path = File.join(base, dir)
      return { count: 0, files: [] } unless Dir.exist?(path)

      files = Dir.glob("#{path}/**/*.rb").map { |f| f.gsub(base + '/', '') }
      { count: files.count, files: files }
    end

    def self.detect_database(path)
      db_file = File.join(path, "config/database.yml")
      return 'Unknown' unless File.exist?(db_file)

      config = safe_yaml_load(db_file)
      config["development"]["adapter"] rescue "Unknown"
    end

    # def self.get_routes(path)
    #   output = `cd #{path} && RAILS_ENV=development bundle exec rails routes 2>/dev/null`
    #   output.empty? ? "No routes found or Rails not installed" : output
    # end

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
      File.exist?(file) ? Digest::MD5.hexdigest(File.read(file)) : nil
    end

    def self.get_git_log(path)
      return [] unless File.exist?(File.join(path, ".git"))
      Dir.chdir(path) do
        log = `git log --pretty=format:'%h - %an (%ad): %s' --date=short -n 20 2>/dev/null`
        log.split("\n")
      end
    rescue => e
      ["Error reading git log: #{e.message}"]
    end

def self.analyze_models(path)
  result = { count: 0, files: [], detailed: {} }

  ActiveSupport::Dependencies.autoload_paths += Dir["#{path}/app/models/**/"]

  Dir.glob("#{path}/app/models/**/*.rb").each do |file|
    next unless File.exist?(file)

    relative_path = file.gsub("#{path}/", '')
    model_name = relative_path.sub('app/models/', '').sub('.rb', '').camelize

    begin
      require_dependency file

      begin
        model_class = model_name.safe_constantize
      rescue => e
        result[:detailed][model_name] = { error: "safe_constantize failed: #{e.class} - #{e.message}" }
        next
      end

      unless model_class && model_class < ActiveRecord::Base
        result[:detailed][model_name] = { error: "Not an ActiveRecord model or constant not found." }
        next
      end

      result[:count] += 1
      result[:files] << relative_path

      # Validations
      validations = Hash.new { |hash, key| hash[key] = [] }
      model_class.validators.each do |validator|
        validator.attributes.each do |attr|
          validations[attr] << validator.class.name.demodulize.underscore
        end
      end

      # Callbacks
      callbacks = {}
      ActiveRecord::Callbacks::CALLBACKS.each do |cb|
        if model_class.respond_to?("_#{cb}_callbacks")
          methods = model_class.send("_#{cb}_callbacks").map(&:filter).uniq
          callbacks[cb] = methods.map(&:to_s) if methods.any?
        end
      end

      # Enums
      enums = model_class.defined_enums.transform_values { |v| v.keys }

      # Associations with polymorphic check
      raw_associations = model_class.reflect_on_all_associations
      associations = raw_associations.group_by(&:macro).transform_values { |a| a.map(&:name) }
      polymorphic_associations = raw_associations.select { |a| a.options[:polymorphic] }.map(&:name)

      # Scopes
      scopes = model_class.methods(false).select do |method|
        model_class.method(method).source_location&.first&.include?('/models/')
      end.select { |m| model_class.respond_to?(m) && model_class.send(m).is_a?(ActiveRecord::Relation) rescue false }

      # Class & Instance methods
      class_methods = (model_class.methods(false) - ActiveRecord::Base.methods)
      instance_methods = (model_class.instance_methods(false) - ActiveRecord::Base.instance_methods).map(&:to_s)

      result[:detailed][model_class.name] = {
        table_name: model_class.table_name,
        file: relative_path,
        attributes: model_class.columns.map(&:name),
        attribute_defaults: model_class.columns.each_with_object({}) { |col, hash| hash[col.name] = col.default },
        sti: model_class.columns.any? { |col| col.name == model_class.inheritance_column },
        polymorphic_associations: polymorphic_associations,
        associations: associations,
        validations: validations,
        enums: enums,
        callbacks: callbacks,
        scopes: scopes.map(&:to_s),
        class_methods: class_methods.map(&:to_s),
        instance_methods: instance_methods,
        methods_count: model_class.instance_methods(false).count
      }

    rescue => e
      result[:detailed][model_name] = { error: "Failed to load model: #{e.class} - #{e.message}" }
    end
  end

  result
end



    def self.export(path, format = :json)
      file = "#{path}/activity_tracker/report.yml"
      return puts "❌ Report not found." unless File.exist?(file)

      data = safe_yaml_load(file)

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
              value.each { |k, v| csv << ["  #{k}", v.to_json] }
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
