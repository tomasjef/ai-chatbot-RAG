class EmbeddingService
  MODEL = "text-embedding-3-small"
  # Well inside OpenAI's per-request limits for 150-word passages
  BATCH_SIZE = 100

  def self.call(text)
    new.call(text)
  end

  # One request per BATCH_SIZE passages, so long PDFs finish within Heroku's 30 second limit
  def self.batch(texts)
    new.batch(texts)
  end

  def call(text)
    response = client.embeddings(parameters: { model: MODEL, input: text })
    response.dig("data", 0, "embedding")
  end

  def batch(texts)
    Array(texts).each_slice(BATCH_SIZE).flat_map do |slice|
      response = client.embeddings(parameters: { model: MODEL, input: slice })
      response.fetch("data").sort_by { |item| item["index"] }.map { |item| item["embedding"] }
    end
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end
end
