OpenAI.configure do |config|
  config.access_token =
    ENV["OPENAI_API_KEY"].presence ||
    ENV["OPENAI_ACCESS_TOKEN"].presence ||
    Rails.application.credentials.dig(:openai, :api_key)
end
