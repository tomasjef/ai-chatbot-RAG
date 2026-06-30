class EmbeddingService
  MODEL = "text-embedding-3-small"

  def self.call(text)
    new.call(text)
  end

  def call(text)
    response = client.embeddings(parameters: { model: MODEL, input: text })
    response.dig("data", 0, "embedding")
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end
end
