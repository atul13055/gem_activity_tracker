# 📊 Gem Activity Tracker

**`gem_activity_tracker`** is a Ruby gem that tracks the internal structure, changes, and metadata of your **Ruby** or **Rails** projects. It generates a complete project activity report in **YAML**, with support for **JSON/CSV export**, **auto-tracking with file watcher**, and **Git log visualization**.

---

## 🚀 Features

- 🔍 Analyze project structure: models, controllers, jobs, services, mailers, routes, etc.
- 🧠 Advanced model analysis: attributes, associations, methods, validations, callbacks, and enums.
- 🏗️ Migration tracking and schema hashing.
- 🛠️ Detect database type from `database.yml`.
- 📦 Git history tracking (last 20 commits).
- 🔄 Auto-tracking using the `listen` gem on file changes.
- 📁 Export report to **YAML**, **JSON**, or **CSV**.
- ✅ Works with both **Rails** and **plain Ruby** projects.

---

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'gem_activity_tracker'
```

Then run:

```bash
bundle install
```

Or install it directly:

```bash
gem install gem_activity_tracker
```

---

## ⚙️ Usage

### 📌 Basic CLI Commands

```bash
gem_activity_tracker --track=PATH          # Track a Ruby/Rails project and generate report
gem_activity_tracker --report              # Show last generated report
gem_activity_tracker --export=json         # Export report to JSON
gem_activity_tracker --export=csv          # Export report to CSV
gem_activity_tracker --watch               # Start file watcher to auto-track changes
```

### 🛠️ Rails Auto-Tracking

In a Rails app, the gem automatically hooks into the app after initialization via a Railtie.

Set this in your `.env` or shell:

```bash
export GEM_ACTIVITY_TRACKER_ENABLED=true
```

Then start your Rails app and the gem will:

- Detect and track changes
- Update `activity_tracker/report.yml`
- Start watching the file system

---

## 📂 Output

The gem creates an `activity_tracker/` folder at your project root:

```bash
activity_tracker/
├── report.yml        # Main YAML report
├── report.json       # (Optional) Exported JSON
├── report.csv        # (Optional) Exported CSV
└── log.txt           # File change logs (when watch mode is on)
```

---

## 📊 What’s Tracked?

| Component   | Details                                                                 |
|------------|-------------------------------------------------------------------------|
| Models      | Count, files, attributes, associations, methods, validations, enums     |
| Controllers | List of files                                                           |
| Services    | List of files                                                           |
| Mailers     | List of files                                                           |
| Jobs        | List of files                                                           |
| Migrations  | Count and recent migration names                                        |
| Routes      | Full route listing via `rails routes`                                   |
| Schema      | Schema hash (`db/schema.rb`)                                            |
| Git Log     | Last 20 commits                                                         |
| Database    | Type detected from `config/database.yml`                                |

---

## 🔁 Auto-Watcher

Auto-track changes in real-time using the `listen` gem:

```bash
gem_activity_tracker --watch
```

You'll see logs like:

```
[2025-04-10 12:00:00] Modified: app/models/user.rb
[2025-04-10 12:00:01] Added: app/services/new_service.rb
```

Each change triggers regeneration of the report.

---

## 🧪 Example Output (YAML)

```yaml
ruby_version: ruby 3.2.2
rails_version: 6.1.4
database: postgresql
models:
  count: 5
  files:
    - app/models/user.rb
    - app/models/post.rb
  detailed:
    User:
      table_name: users
      attributes: [id, name, email]
      associations:
        has_many: [posts]
      validations: ["PresenceValidator"]
      callbacks: [before_create, after_save]
controllers:
  count: 3
  files: [...]
git_log:
  - "1a2b3c4 - Atul Yadav (2025-04-10): Add model tracker"
  - ...
```

---

## 💡 Configuration

You can toggle auto-tracking with an ENV variable:

```bash
export GEM_ACTIVITY_TRACKER_ENABLED=false  # disables auto-tracking
```

---

## 🧑 Author

**Atul Yadav**  
📧 atuIyadav9039@gmail.com  
📍 Indore, India  
🔗 [LinkedIn](https://www.linkedin.com/in/atul-yadav-9445ab1a4)  
📦 RubyGems: [gem_activity_tracker](https://rubygems.org/gems/gem_activity_tracker)

---

## 📄 License

This project is licensed under the MIT License. See `LICENSE.txt` for details.

---

## 💬 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.