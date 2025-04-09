# 🚀 GemActivityTracker

**GemActivityTracker** is a Ruby gem that automatically tracks the structure and changes in your Ruby on Rails project. It collects details like models, controllers, jobs, mailers, services, migrations, schema, routes, and Git history. It also provides real-time file change tracking with a detailed activity log and supports exporting the report as JSON or CSV.

---

## 🔍 What Does This Gem Do?

When you include this gem in your Rails project, it will:

- ✅ Scan and record project components:
  - Models, Controllers, Jobs, Mailers, Services
  - Migrations, Routes, Schema hash
  - Database type and Git history
- 🔁 Automatically detect changes after initialization
- 🕵️ Keep an activity log of every file change (created, modified, removed)
- 📊 Export report in:
  - YAML (default)
  - JSON
  - CSV
- 🔁 Real-time file watcher using the `listen` gem

---

## 🔧 Compatibility

- ✅ **Ruby**: >= 2.6.5 and < 4.0
- ✅ **Rails**: >= 5.2 and <= 7.1

- ✅ Works with: **MySQL**, **PostgreSQL**, **SQLite**

---

## 📦 Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'gem_activity_tracker'
```

Then run:

```bash
bundle install
```

Or install it manually:

```bash
gem install gem_activity_tracker
```

---

## 🚀 Basic Usage

Once installed, you can use the CLI commands:

### 1. 📌 Generate Activity Report

```bash
gem_activity_tracker --track=.
```

It will generate a `report.yml` in the `activity_tracker/` folder.

---

### 2. 👁 Start Watching for File Changes

```bash
gem_activity_tracker --watch
```

This will keep watching the project. On any file change (model, controller, migration, etc.), it will:

- Update the report
- Add a new entry to `log.txt`

---

### 3. 📄 View Last Generated Report

```bash
gem_activity_tracker --report
```

---

### 4. 📤 Export Report as JSON

```bash
gem_activity_tracker --export=json
```

---

### 5. 📤 Export Report as CSV

```bash
gem_activity_tracker --export=csv
```

---

## 📁 Output Structure

The following directory is automatically created:

```
activity_tracker/
├── report.yml       # Main YAML report
├── report.json      # (Optional) JSON export
├── report.csv       # (Optional) CSV export
└── log.txt          # Activity logs of file changes
```

---

## 🧪 Development

For contributing or testing locally:

```bash
git clone https://github.com/atul13055/gem_activity_tracker.git
cd gem_activity_tracker
bundle install
```

Run interactive Ruby console:

```bash
bin/console
```

Build the gem locally:

```bash
bundle exec rake install
```

---

## 🚀 Releasing New Version

1. Update version in `lib/gem_activity_tracker/version.rb`
2. Build and release:

```bash
bundle exec rake release
```

This will:

- Create a `.gem` file
- Push to RubyGems
- Tag and push to GitHub

---

## 🤝 Contributing

1. Fork this repo
2. Create a new branch: `git checkout -b my-feature`
3. Make your changes
4. Commit: `git commit -m "Add my feature"`
5. Push: `git push origin my-feature`
6. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

## 🌍 Links

- 📦 [RubyGems Page](https://rubygems.org/gems/gem_activity_tracker)
- 🧠 [GitHub Repo](https://github.com/atul13055/gem_activity_tracker)

---

## 🙌 Author

Built with ❤️ by **Atul Yadav**  
📧 [atuIyadav9039@gmail.com](mailto:atuIyadav9039@gmail.com)  
🌐 [LinkedIn](https://www.linkedin.com/in/atul-yadav-9445ab1a4)