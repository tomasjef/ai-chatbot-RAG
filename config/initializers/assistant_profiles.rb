profiles_path = Rails.root.join("config/assistant_profiles.yml")
profiles = YAML.load_file(profiles_path) || {}

Rails.configuration.x.assistant_profiles = profiles.deep_stringify_keys
